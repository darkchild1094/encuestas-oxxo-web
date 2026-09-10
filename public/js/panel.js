/*
 * panel.js -- navegacion sin recarga para el panel web.
 *
 * Mejora progresiva: intercepta los submit de formularios y los clicks de
 * enlaces DENTRO del area de contenido (#contenido), hace la peticion por
 * fetch() y reemplaza solo ese bloque. Los controladores no cambian: siguen
 * respondiendo con header('Location: ...') y fetch(redirect:'follow') sigue
 * el 302 y devuelve el HTML de la pagina final.
 *
 * Los links de la barra superior (.topnav) quedan FUERA de #contenido, asi
 * que siguen navegando con recarga completa -- a proposito.
 *
 * Sin dependencias. Si algo falla, cae a window.location (recarga normal) y
 * el usuario nunca queda atrapado.
 */
(function () {
  'use strict';

  var CONTENIDO = '#contenido';
  var enVuelo = false;

  function porId(id) { return document.getElementById(id); }
  function contenido() { return document.querySelector(CONTENIDO); }

  // --- barra de progreso superior --------------------------------------
  function progreso(on) {
    var b = porId('panel-progress');
    if (b) { b.classList.toggle('activo', !!on); }
    document.body.classList.toggle('is-loading', !!on);
  }

  // --- swap del contenido --------------------------------------------------
  function intercambiar(html, url, empujar) {
    var doc = new DOMParser().parseFromString(html, 'text/html');
    var nuevo = doc.querySelector(CONTENIDO);
    var viejo = contenido();
    if (!nuevo || !viejo) {
      // La respuesta no es una pagina del panel (login, error, etc.):
      // recarga dura para que el usuario vea lo que sea que devolvio.
      window.location.href = url;
      return;
    }
    viejo.innerHTML = nuevo.innerHTML;

    var t = doc.querySelector('title');
    if (t) { document.title = t.textContent; }

    if (url) {
      if (empujar) { history.pushState({ panel: true }, '', url); }
      else { history.replaceState({ panel: true }, '', url); }
    }

    mejorar(viejo);
    reiniciarBootstrap(viejo);
    viejo.scrollIntoView({ block: 'start', behavior: 'auto' });
    // enfoca el primer campo del contenido nuevo si hay un formulario visible
    var foco = viejo.querySelector('input:not([type=hidden]):not([disabled]), select, textarea');
    if (foco && foco.closest('details[open], form')) { try { foco.focus({ preventScroll: true }); } catch (e) {} }
  }

  function reiniciarBootstrap(scope) {
    // Bootstrap 5 maneja data-bs-dismiss por delegacion en document, no hace
    // falta re-inicializar. Si algun dia se usan tooltips/dropdowns via JS,
    // inicializarlos aqui.
  }

  // --- peticiones -------------------------------------------------------
  function traer(url, opciones, empujar) {
    if (enVuelo) { return; }
    enVuelo = true;
    progreso(true);
    opciones = opciones || {};
    opciones.headers = Object.assign({ 'X-Requested-With': 'fetch' }, opciones.headers || {});
    opciones.redirect = 'follow';
    opciones.credentials = 'same-origin';

    fetch(url, opciones)
      .then(function (r) {
        var ct = r.headers.get('content-type') || '';
        if (!r.ok || ct.indexOf('text/html') === -1) {
          // 419/403/500 o algo que no es HTML: recarga dura.
          window.location.href = r.url || url;
          return null;
        }
        return r.text().then(function (html) { return { html: html, url: r.url || url }; });
      })
      .then(function (res) {
        if (res) { intercambiar(res.html, res.url, empujar); }
      })
      .catch(function () {
        window.location.href = url;
      })
      .finally(function () {
        enVuelo = false;
        progreso(false);
      });
  }

  // --- interceptores ---------------------------------------------------
  function esExterno(a) {
    return a.hasAttribute('download') ||
      a.target === '_blank' || a.target === '_top' ||
      a.classList.contains('no-ajax') ||
      /\/respuestas\/exportar/.test(a.getAttribute('href') || '') ||
      a.origin !== window.location.origin;
  }

  document.addEventListener('click', function (e) {
    if (e.defaultPrevented || e.button !== 0 || e.metaKey || e.ctrlKey || e.shiftKey || e.altKey) { return; }
    var a = e.target.closest('a[href]');
    if (!a || !contenido().contains(a)) { return; }
    var href = a.getAttribute('href');
    if (!href || href.charAt(0) === '#' || href.indexOf('javascript:') === 0) { return; }
    if (esExterno(a)) { return; }
    e.preventDefault();
    traer(a.href, { method: 'GET' }, true);
  });

  document.addEventListener('submit', function (e) {
    if (e.defaultPrevented) { return; } // onsubmit="return confirm(...)" cancelado
    var form = e.target;
    if (!(form instanceof HTMLFormElement) || !contenido().contains(form)) { return; }
    if (form.hasAttribute('data-no-ajax') || form.target) { return; }

    e.preventDefault();
    var metodo = (form.method || 'GET').toUpperCase();
    var accion = form.action;
    var fd = new FormData(form);

    // boton pulsado: incluir su name/value y deshabilitarlo mientras vuela
    var btn = e.submitter || form.querySelector('button[type=submit], input[type=submit]');
    if (btn && btn.name) { fd.append(btn.name, btn.value || ''); }
    if (btn) { btn.disabled = true; setTimeout(function () { btn.disabled = false; }, 8000); }

    if (metodo === 'GET') {
      var qs = new URLSearchParams(fd).toString();
      var url = accion + (qs ? '?' + qs : '');
      traer(url, { method: 'GET' }, true);
      if (btn) { btn.disabled = false; }
    } else {
      traer(accion, { method: metodo, body: fd }, false);
      if (btn) { setTimeout(function () { btn.disabled = false; }, 500); }
    }
  });

  window.addEventListener('popstate', function (e) {
    if (e.state && e.state.panel) {
      traer(window.location.href, { method: 'GET' }, false);
    }
  });

  // --- mejoras que hay que re-aplicar tras cada swap ------------------
  function mejorar(scope) {
    scope = scope || document;
    // selects con onchange="this.form.submit()": .submit() NO dispara el
    // listener de 'submit', asi que lo cambiamos por requestSubmit().
    scope.querySelectorAll('select[onchange]').forEach(function (sel) {
      var oc = sel.getAttribute('onchange') || '';
      if (oc.indexOf('this.form.submit') === -1) { return; }
      sel.removeAttribute('onchange');
      if (sel.dataset.autosubmit) { return; }
      sel.dataset.autosubmit = '1';
      sel.addEventListener('change', function () {
        if (sel.form) {
          if (sel.form.requestSubmit) { sel.form.requestSubmit(); }
          else { sel.form.dispatchEvent(new Event('submit', { cancelable: true, bubbles: true })); }
        }
      });
    });
  }

  // --- copiar-enlace (antes vivia inline dentro de #contenido) --------
  document.addEventListener('click', function (ev) {
    var boton = ev.target.closest('.js-copiar-enlace');
    if (!boton) { return; }
    var campo = boton.closest('.copy-link') && boton.closest('.copy-link').querySelector('input');
    if (!campo) { return; }
    campo.select();
    campo.setSelectionRange(0, 99999);
    var avisar = function () {
      var t = boton.textContent;
      boton.textContent = 'Copiado';
      boton.disabled = true;
      setTimeout(function () { boton.textContent = t; boton.disabled = false; }, 1500);
    };
    if (navigator.clipboard && window.isSecureContext) {
      navigator.clipboard.writeText(campo.value).then(avisar, function () { document.execCommand('copy'); avisar(); });
    } else {
      document.execCommand('copy');
      avisar();
    }
  });

  // arranque
  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', function () {
      history.replaceState({ panel: true }, '', window.location.href);
      mejorar(contenido());
    });
  } else {
    history.replaceState({ panel: true }, '', window.location.href);
    mejorar(contenido());
  }
})();
