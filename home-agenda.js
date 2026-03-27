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
        return '#1A1A2E';
      case 'Matem\u00E1tica':
        return '#7A3410';
      case 'Ci\u00EAncias':
        return '#1A5C3A';
      case 'Geografia':
        return '#00a545';
      case 'Hist\u00F3ria':
        return '#8B4513';
      case 'Ingl\u00EAs':
        return '#4361EE';
      case 'Ensino Religioso':
        return '#845EC2';
      case 'Reda\u00E7\u00E3o':
        return '#EF476F';
      default:
        return '#777777';
    }
  }

  function normalizeItem(item) {
    return {
      ...item,
      tipo: item.tipo || 'evento',
      materia: fixMojibake(item.materia || 'Geral'),
      titulo: fixMojibake(item.titulo || item.resumo_original || 'Sem titulo')
    };
  }

  function ensureEventsSection() {
    if (document.getElementById('agenda-eventos')) return;

    const main = document.querySelector('main');
    if (!main) return;

    const section = document.createElement('section');
    section.className = 'home-section';
    section.innerHTML = [
      '<div class="section-label">Eventos e avisos</div>',
      '<div class="agenda-card">',
      '<div class="agenda-card-titulo">',
      '<span>Agenda geral da turma</span>',
      '<span class="agenda-badge agenda-badge-eventos">Eventos</span>',
      '</div>',
      '<div id="agenda-eventos" class="agenda-lista">',
      '<div class="agenda-vazia">Carregando eventos...</div>',
      '</div>',
      '</div>'
    ].join('');

    main.appendChild(section);
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

  function createAgendaItem(item, showDate) {
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
    title.className = 'agenda-titulo';
    title.textContent = item.titulo;

    article.appendChild(top);
    article.appendChild(title);

    if (item.tipo === 'prova') {
      const meta = document.createElement('div');
      meta.className = 'agenda-meta';
      meta.textContent = 'Avalia\u00E7\u00E3o marcada no calend\u00E1rio da turma';
      article.appendChild(meta);
    }

    return article;
  }

  function renderAgendaSection(targetId, items, emptyMessage, showDate) {
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
      container.appendChild(createAgendaItem(normalizeItem(item), showDate));
    });
  }

  async function hydrateAgenda() {
    fixHomeLabels();
    ensureEventsSection();

    const errorMessage = 'N\u00E3o foi poss\u00EDvel carregar a agenda agora.';

    try {
      const response = await fetch('data/tarefas.json', { cache: 'no-store' });
      if (!response.ok) {
        throw new Error('Falha ao carregar agenda');
      }

      const data = await response.json();
      const items = Array.isArray(data.itens) ? data.itens : [];
      const tarefas = items.filter((item) => item.tipo === 'tarefa');
      const provas = items
        .filter((item) => item.tipo === 'prova')
        .sort((a, b) => (a.prazo || '').localeCompare(b.prazo || ''))
        .slice(0, 6);
      const eventos = items
        .filter((item) => item.tipo === 'evento' || item.tipo === 'aviso')
        .sort((a, b) => (a.prazo || '').localeCompare(b.prazo || ''))
        .slice(0, 6);

      const hoje = tarefas.filter((item) => item.urgencia === 'hoje');
      const amanha = tarefas.filter((item) => item.urgencia === 'amanha');
      const proximos = tarefas.filter((item) =>
        item.urgencia === 'esta_semana' || item.urgencia === 'proximos_dias'
      );

      renderAgendaSection('agenda-hoje', hoje, 'Nenhuma tarefa com prazo para hoje.', false);
      renderAgendaSection('agenda-amanha', amanha, 'Nenhuma tarefa com prazo para amanh\u00E3.', false);
      renderAgendaSection('agenda-proximos', proximos, 'Nenhum prazo pr\u00F3ximo encontrado.', true);
      renderAgendaSection('agenda-provas', provas, 'Nenhuma prova pr\u00F3xima encontrada.', true);
      renderAgendaSection('agenda-eventos', eventos, 'Nenhum evento importante encontrado.', true);
    } catch (error) {
      ['agenda-hoje', 'agenda-amanha', 'agenda-proximos', 'agenda-provas', 'agenda-eventos'].forEach((targetId) => {
        const container = document.getElementById(targetId);
        if (container) {
          container.innerHTML = '<div class="agenda-erro">' + errorMessage + '</div>';
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
