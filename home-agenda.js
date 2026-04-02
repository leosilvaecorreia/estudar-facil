(function () {
  function fixMojibake(text) {
    if (!text || typeof text !== 'string') return '';

    let current = text;
    for (let i = 0; i < 2; i += 1) {
      if (!/[ÃÂ]/.test(current)) break;
      try {
        current = decodeURIComponent(escape(current));
      } catch (error) {
        break;
      }
    }

    return current;
  }

  function formatDate(dateString) {
    if (!dateString) return '';
    const [year, month, day] = dateString.split('-').map(Number);
    const date = new Date(year, month - 1, day);
    return new Intl.DateTimeFormat('pt-BR', {
      day: '2-digit',
      month: '2-digit'
    }).format(date);
  }

  function getMateriaColor(materia) {
    switch (materia) {
      case 'Portugu\u00EAs':
        return '#2D2B55';
      case 'Matem\u00E1tica':
        return '#7A3410';
      case 'Ci\u00EAncias':
        return '#1A5C3A';
      case 'Geografia':
        return '#00a545';
      case 'Hist\u00F3ria':
        return '#C0392B';
      case 'Ingl\u00EAs':
        return '#4361EE';
      case 'Ensino Religioso':
        return '#845EC2';
      case 'Pensamento Computacional':
        return '#0F766E';
      case 'Projeto de Leitura':
        return '#C05621';
      case 'Reda\u00E7\u00E3o':
        return '#EF476F';
      default:
        return '#777777';
    }
  }

  function normalizeKey(value) {
    return fixMojibake(value || '')
      .normalize('NFD')
      .replace(/[\u0300-\u036f]/g, '')
      .replace(/\s+/g, ' ')
      .trim()
      .toUpperCase();
  }

  function buildProvaKey(item) {
    return [
      normalizeKey(item.titulo || ''),
      normalizeKey(item.materia || ''),
      item.prazo || ''
    ].join('|');
  }

  function buildProvaLookup(data) {
    const lookup = new Map();
    const items = Array.isArray(data && data.itens) ? data.itens : [];

    items.forEach((item) => {
      const key = [
        normalizeKey(item.titulo_prova || ''),
        normalizeKey(item.materia || ''),
        item.data || ''
      ].join('|');

      lookup.set(key, {
        ...item,
        titulo_prova: fixMojibake(item.titulo_prova || ''),
        materia: fixMojibake(item.materia || ''),
        conteudos: Array.isArray(item.conteudos)
          ? item.conteudos.map((conteudo) => fixMojibake(conteudo))
          : []
      });
    });

    return lookup;
  }

  async function loadProvaLookup() {
    try {
      if (window.__MATERIAS_PROVAS_DATA) {
        return buildProvaLookup(window.__MATERIAS_PROVAS_DATA);
      }

      const response = await fetch('data/materias_provas.json', { cache: 'no-store' });
      if (!response.ok) return new Map();

      const data = await response.json();
      return buildProvaLookup(data);
    } catch (error) {
      return new Map();
    }
  }

  async function loadAgendaData() {
    const isLocalFile = window.location.protocol === 'file:';

    if (isLocalFile && window.__TAREFAS_DATA && Array.isArray(window.__TAREFAS_DATA.itens)) {
      return window.__TAREFAS_DATA;
    }

    try {
      const response = await fetch('data/tarefas.json', { cache: 'no-store' });
      if (!response.ok) {
        throw new Error('Falha ao carregar agenda');
      }

      return await response.json();
    } catch (error) {
      if (window.__TAREFAS_DATA && Array.isArray(window.__TAREFAS_DATA.itens)) {
        return window.__TAREFAS_DATA;
      }

      throw error;
    }
  }

  function normalizeItem(item) {
    return {
      ...item,
      tipo: item.tipo || 'evento',
      materia: fixMojibake(item.materia || 'Geral'),
      titulo: fixMojibake(item.titulo || item.resumo_original || 'Sem titulo'),
      descricao: fixMojibake(item.descricao || '')
    };
  }

  function ensureEventsSection() {
    if (document.getElementById('agenda-eventos')) return;

    const panels = document.getElementById('home-secondary-panels');
    if (!panels) return;

    const section = document.createElement('section');
    section.className = 'home-section';
    section.innerHTML = [
      '<div class="section-label">Eventos e avisos</div>',
      '<div class="agenda-card">',
      '<div id="agenda-eventos" class="agenda-lista">',
      '<div class="agenda-vazia">Carregando eventos...</div>',
      '</div>',
      '</div>'
    ].join('');

    panels.appendChild(section);
  }

  function fixHomeLabels() {
    const agendaCards = document.querySelectorAll('.home-section .agenda-card');
    if (agendaCards[0]) {
      const spans = agendaCards[0].querySelectorAll('.agenda-card-titulo span');
      if (spans[0]) spans[0].textContent = 'Tarefas para hoje';
    }
    if (agendaCards[1]) {
      const spans = agendaCards[1].querySelectorAll('.agenda-card-titulo span');
      if (spans[0]) spans[0].textContent = 'Tarefas de amanh\u00E3';
      if (spans[1]) spans[1].textContent = 'Amanh\u00E3';
    }
    if (agendaCards[2]) {
      const spans = agendaCards[2].querySelectorAll('.agenda-card-titulo span');
      if (spans[0]) spans[0].textContent = 'Pr\u00F3ximos prazos';
    }

    const sectionLabels = document.querySelectorAll('.home-section .section-label');
    if (sectionLabels[1]) sectionLabels[1].textContent = 'Pr\u00F3ximas provas';
  }

  function createAgendaItem(item, showDate, provaLookup) {
    const article = document.createElement('article');
    article.className = 'agenda-item';
    article.style.setProperty('--materia-cor', getMateriaColor(item.materia));

    const top = document.createElement('div');
    top.className = 'agenda-item-topo';

    const materia = document.createElement('span');
    materia.className = 'agenda-materia';
    materia.textContent = item.materia;
    top.appendChild(materia);

    if (showDate && item.prazo) {
      const date = document.createElement('span');
      date.className = 'agenda-data';
      date.textContent = formatDate(item.prazo);
      top.appendChild(date);
    }

    const title = document.createElement('div');
    title.className = 'agenda-titulo agenda-titulo-resumo';
    title.textContent = item.titulo;

    article.appendChild(top);
    article.appendChild(title);

    const detalhes = item.descricao && item.descricao !== item.titulo ? item.descricao : '';
    const hasLongTitle = item.titulo.length > 60;
    const hasExtraDetails = detalhes.length > 0;
    const needsToggle = hasExtraDetails || hasLongTitle;

    if (needsToggle) {
      const toggle = document.createElement('button');
      toggle.type = 'button';
      toggle.className = 'agenda-toggle';
      toggle.textContent = 'Ver detalhes';
      let detailsBox = null;

      toggle.addEventListener('click', () => {
        const expanded = toggle.getAttribute('aria-expanded') === 'true';
        const nextExpanded = !expanded;

        toggle.setAttribute('aria-expanded', nextExpanded ? 'true' : 'false');
        toggle.textContent = expanded ? 'Ver detalhes' : 'Ocultar detalhes';

        if (hasExtraDetails) {
          detailsBox.hidden = expanded;
        } else {
          title.classList.toggle('agenda-titulo-resumo', expanded);
        }
      });

      article.appendChild(toggle);

      if (hasExtraDetails) {
        detailsBox = document.createElement('div');
        detailsBox.className = 'agenda-detalhes';
        detailsBox.hidden = true;
        detailsBox.textContent = detalhes;
        article.appendChild(detailsBox);
      }
    }

    if (item.tipo === 'prova') {
      const meta = document.createElement('div');
      meta.className = 'agenda-meta';
      meta.textContent = 'Avalia\u00E7\u00E3o marcada no calend\u00E1rio da turma';
      article.appendChild(meta);

      const provaInfo = provaLookup ? provaLookup.get(buildProvaKey(item)) : null;
      const hasConteudos = provaInfo && Array.isArray(provaInfo.conteudos) && provaInfo.conteudos.length > 0;

      if (hasConteudos) {
        const toggle = document.createElement('button');
        toggle.type = 'button';
        toggle.className = 'agenda-toggle';
        toggle.textContent = 'Mat\u00E9ria da prova';

        const detailsBox = document.createElement('div');
        detailsBox.className = 'agenda-detalhes';
        detailsBox.hidden = true;

        const list = document.createElement('ul');
        list.className = 'agenda-detalhes-lista';

        provaInfo.conteudos.forEach((conteudo) => {
          const itemEl = document.createElement('li');
          itemEl.textContent = conteudo;
          list.appendChild(itemEl);
        });

        detailsBox.appendChild(list);

        toggle.addEventListener('click', () => {
          const expanded = toggle.getAttribute('aria-expanded') === 'true';
          const nextExpanded = !expanded;
          toggle.setAttribute('aria-expanded', nextExpanded ? 'true' : 'false');
          toggle.textContent = expanded ? 'Mat\u00E9ria da prova' : 'Ocultar mat\u00E9ria';
          detailsBox.hidden = expanded;
        });

        article.appendChild(toggle);
        article.appendChild(detailsBox);
      }
    }

    return article;
  }

  function renderAgendaSection(targetId, items, emptyMessage, showDate, provaLookup) {
    const container = document.getElementById(targetId);
    if (!container) return;

    container.innerHTML = '';

    if (!items.length) {
      const empty = document.createElement('div');
      empty.className = 'agenda-vazia';
      empty.textContent = emptyMessage;
      container.appendChild(empty);
      return;
    }

    items.forEach((item) => {
      container.appendChild(createAgendaItem(normalizeItem(item), showDate, provaLookup));
    });
  }

  async function hydrateAgenda() {
    fixHomeLabels();
    ensureEventsSection();

    const errorMessage = 'N\u00E3o foi poss\u00EDvel carregar a agenda agora.';

    try {
      const data = await loadAgendaData();
      const provaLookup = await loadProvaLookup();
      const items = Array.isArray(data.itens) ? data.itens : [];
      const tarefas = items.filter((item) => item.tipo === 'tarefa');
      const sortByPrazo = (a, b) => (a.prazo || '').localeCompare(b.prazo || '');
      const provas = items
        .filter((item) => item.tipo === 'prova')
        .sort(sortByPrazo)
        .slice(0, 6);
      const eventos = items
        .filter((item) => item.tipo === 'evento' || item.tipo === 'aviso')
        .sort(sortByPrazo)
        .slice(0, 6);

      const hoje = tarefas.filter((item) => item.urgencia === 'hoje').sort(sortByPrazo);
      const amanha = tarefas.filter((item) => item.urgencia === 'amanha').sort(sortByPrazo);
      const proximos = tarefas.filter((item) =>
        item.urgencia === 'esta_semana' || item.urgencia === 'proximos_dias'
      ).sort(sortByPrazo);

      renderAgendaSection('agenda-hoje', hoje, 'Nenhuma tarefa com prazo para hoje.', false, provaLookup);
      renderAgendaSection('agenda-amanha', amanha, 'Nenhuma tarefa com prazo para amanh\u00E3.', false, provaLookup);
      renderAgendaSection('agenda-proximos', proximos, 'Nenhum prazo pr\u00F3ximo encontrado.', true, provaLookup);
      renderAgendaSection('agenda-provas', provas, 'Nenhuma prova pr\u00F3xima encontrada.', true, provaLookup);
      renderAgendaSection('agenda-eventos', eventos, 'Nenhum evento importante encontrado.', true, provaLookup);
    } catch (error) {
      const details = error && error.message ? ' Erro: ' + error.message : '';
      ['agenda-hoje', 'agenda-amanha', 'agenda-proximos', 'agenda-provas', 'agenda-eventos'].forEach((targetId) => {
        const container = document.getElementById(targetId);
        if (container) {
          container.innerHTML = '<div class="agenda-erro">' + errorMessage + details + '</div>';
        }
      });
    }
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', hydrateAgenda);
  } else {
    hydrateAgenda();
  }
})();
