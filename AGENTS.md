# AGENTS.md

## Objetivo Deste Projeto

Este projeto existe para apoiar o estudo de criancas do 4o ano por meio de flashcards, quizzes, revisoes e agenda escolar. O foco principal nao e produzir conteudo escolar generico, mas sim criar materiais alinhados ao contexto real em que a escola ensina e cobra as avaliacoes.

## Principio Central

Todo conteudo novo deve partir primeiro do material real da escola.

Isso inclui, quando disponivel:

- materia da prova
- roteiros enviados pelos professores
- exercicios
- paginas do livro
- tarefas de casa
- resumos usados em sala
- listas, folhas e exemplos ja trabalhados com a turma
- eventos e avisos publicados no calendario da turma

Conhecimento geral pode ser usado para complementar, organizar e esclarecer, mas nunca deve substituir o contexto escolar como fonte principal de decisao.

## Como Trabalhar Neste Repositorio

Ao receber novo conteudo ou uma nova tarefa, seguir esta ordem:

1. Entender o que a escola realmente esta cobrando.
2. Identificar o vocabulario, o recorte e o nivel de dificuldade usados pela turma.
3. Separar o que e conteudo essencial, o que e detalhe cobravel e o que e so complemento.
4. Montar flashcards, quizzes, resumos e agenda com base nesse recorte.
5. Manter a linguagem apropriada para criancas do 4o ano.

Antes de propor novos padroes, fluxos, componentes ou solucoes de produto, consultar este `AGENTS.md` para verificar:

- regras ja decididas com o usuario
- padroes visuais e estruturais ja adotados
- restricoes operacionais do projeto
- comportamento esperado da agenda, provas e home

## Regras De Conteudo

- Priorizar aderencia ao material da escola acima de abrangencia.
- Evitar expandir demais para assuntos fora do escopo da prova.
- Preservar, sempre que possivel, a terminologia usada pelo professor e pelo material didatico.
- Preferir exemplos parecidos com os vistos em sala, no livro ou nas tarefas.
- Nao transformar o conteudo em algo mais dificil do que a escola espera.
- Nao simplificar tanto a ponto de perder o formato em que o conteudo costuma ser cobrado.

## Regras De Producao

- Trabalhar por tarefa e dentro de escopo definido.
- Antes de publicar alteracoes, sempre apresentar um resumo claro do que foi mudado.
- Usar branch por tarefa.
- Fluxo enxuto acordado:
  - criar ou usar uma branch da tarefa
  - fazer as alteracoes dentro do escopo
  - mostrar um resumo claro do que mudou
  - com uma unica aprovacao do usuario, fazer commit, push e merge

## Fluxo De Publicacao No GitHub

O fluxo padrao deste projeto para envio ao GitHub e:

1. criar uma branch por tarefa
2. realizar apenas as alteracoes do escopo pedido
3. apresentar ao usuario um resumo objetivo das mudancas
4. apos uma unica aprovacao do usuario, executar:
   - commit
   - push da branch
   - merge na `main`

## Regras De Publicacao

- Nao fazer commit sem resumo previo.
- Nao publicar alteracoes fora do escopo pedido.
- Nao abrir novas frentes de mudanca no meio da tarefa sem alinhamento.
- Preferir merge simples e direto quando o usuario aprovar a publicacao.
- Se houver bloqueio tecnico no fluxo de publicacao, explicar claramente o que faltou e em qual etapa.
- Nao executar em paralelo comandos Git que dependem de ordem, como `checkout`, `add`, `commit`, `merge`, `rebase`, `pull`, `push` e validacoes do branch atual.
- Em fluxos de publicacao, tratar mudanca de branch, staging, commit, merge e push como etapas sequenciais.
- Antes de `commit`, confirmar explicitamente o branch atual e o estado do staging quando tiver havido troca recente de branch.
- Antes de `merge`, confirmar explicitamente que o branch atual e a `main` e que o commit esperado esta no branch da tarefa.
- Nunca usar execucao paralela para etapas de publicacao que alterem o estado do repositorio.

## Regras Para Novos Materiais

Quando o usuario enviar novo conteudo da escola, o agente deve:

1. Primeiro interpretar e organizar o material.
2. Depois propor a estrutura ideal de estudo, quando isso ajudar.
3. So entao transformar o conteudo em paginas, flashcards, quiz, resumo ou agenda.

## Organizacao Atual Do Projeto

O projeto e um site estatico simples, sem build e sem backend.

Estrutura atual:

- `index.html` como pagina inicial e hub das materias
- uma pagina HTML por disciplina
- estilos e scripts inline nas paginas antigas
- `home-agenda.js` para a logica complementar da agenda na home
- `scripts/sync_calendar.ps1` para sincronizar o calendario
- `data/tarefas.json` como fonte de dados da home
- pasta `imagens/` para imagens didaticas locais
- `.github/workflows/sync-calendar.yml` para automacao

Cada pagina de materia e autonoma e costuma reunir no mesmo arquivo:

- estrutura HTML
- CSS da pagina
- conteudo didatico
- logica das abas
- logica do quiz
- area de resumo para impressao

## Padrao Estrutural Das Paginas De Materia

Ao criar novas paginas ou expandir paginas existentes, preservar o padrao ja usado:

- botao de volta para a home no topo
- `header` escuro com titulo e subtitulo da materia
- navegacao por abas com botoes arredondados
- menu de abas no padrao de Historia, com container horizontal rolavel (`.tabs-scroll`)
- secoes com `.section` e alternancia por classe `.active`
- blocos de conteudo em cards
- area separada para quiz
- area separada para resumo e impressao

Fluxo visual esperado dentro de uma pagina:

1. identificacao da materia no topo
2. navegacao por abas
3. conteudo principal em cards e blocos didaticos
4. quiz com feedback imediato
5. revisao final
6. resumo para impressao

## Componentes Visuais Que Devem Permanecer Consistentes

Manter a linguagem visual ja estabelecida:

- cantos arredondados generosos, geralmente entre `20px` e `24px`
- cards com sombra vertical marcante
- cores fortes e ludicas, sem aparencia corporativa
- tipografia principal com `Nunito`
- titulos e destaques com `Fredoka One`
- botoes em formato pilula
- badges e chips arredondados
- uso frequente de grids responsivos para cards

Padroes recorrentes que devem ser preservados:

- `.btn-home`
- `.tabs-scroll`
- `header` com fundo escuro e textura suave
- `.tabs` e `.tab-btn`
- `.section` e `.section.active`
- `.cards-grid` ou grids equivalentes
- `.dica-card`
- `.quiz-shell`
- `.resultado-shell`
- `.resumo-controles`
- `.resumo-preview`

## Padrao De Cores

Existe uma base visual comum entre as materias:

- fundo geral claro
- topo com fundo escuro `#1A1A2E`
- amarelo de destaque recorrente `#FFD93D`
- paleta viva com laranja, verde, azul, rosa e roxo

Cada materia usa uma cor principal propria para criar identidade:

- Portugues: azul, roxo e laranja
- Ciencias: verde e turquesa
- Matematica: laranja, azul e marrom
- Geografia: verdes e azuis
- Historia: marrom, vermelho e azul terroso

Regras de uso:

- manter alto contraste entre texto e fundo
- preservar a cor principal da materia em abas ativas, badges e destaques
- usar branco para superficies internas de quiz, resultado e resumo
- evitar reinventar a paleta completa a cada atualizacao pequena
- nao introduzir temas visuais que destoem da linguagem infantil ja existente

Paleta oficial por materia:

- Portugues
  - home e header: `#1A1A2E` -> `#2D2B55`
  - agenda: `#2D2B55`
- Ciencias
  - home e header: `#0D2B1F` -> `#1A5C3A`
  - agenda: `#1A5C3A`
- Matematica
  - home e header: `#3D1A00` -> `#7A3410`
  - agenda: `#7A3410`
- Geografia
  - home e header: `#02350b` -> `#00a545`
  - agenda: `#00a545`
- Historia
  - home e header: `#7A2D23` -> `#C0392B`
  - agenda: `#C0392B`
- Ingles
  - home e header: `#2447D5` -> `#4361EE`
  - agenda: `#4361EE`
- Ensino Religioso
  - home e header: `#6A45A8` -> `#845EC2`
  - agenda: `#845EC2`
- Pensamento Computacional
  - home e header: `#0B5D56` -> `#0F766E`
  - agenda: `#0F766E`
- Projeto de Leitura
  - home e header: `#8C4B1F` -> `#C05621`
  - agenda: `#C05621`
- Redacao
  - home e header: `#D83A67` -> `#EF476F`
  - agenda: `#EF476F`

Regras para novas paginas:

- toda pagina nova deve declarar `--subject-primary` e `--subject-secondary`
- o `header` da materia deve usar `linear-gradient(135deg, var(--subject-primary), var(--subject-secondary))`
- o `h1` do header deve usar `color: white`
- a cor da materia na agenda deve seguir a mesma paleta oficial
- nao reutilizar a cor de outra materia so por proximidade visual

## Padrao Da Home

A home tem um papel especifico e deve continuar simples, mesmo com a agenda:

- apresentar as materias como cards grandes clicaveis no topo
- usar uma grade responsiva
- mostrar nome da materia, descricao curta e chips de disponibilidade
- manter um card de "Em breve" quando fizer sentido
- preservar o header com identidade do projeto e o aviso no rodape

Ao adicionar novas materias:

- seguir o mesmo formato dos cards existentes
- definir uma cor propria para a materia
- manter descricao curta e uniforme
- usar textos curtos nos chips
- o chip de unidades da home deve ser calculado automaticamente a partir das abas da pagina da materia
- para isso, abas que nao representam conteudo estudavel devem usar `data-home-ignore="true"`

## Agenda Da Turma Na Home

A home agora tambem funciona como painel da turma.

Ordem oficial da home:

1. cards de materias
2. `Agenda da turma`
3. `Proximas provas`
4. `Eventos e avisos`

Regras da home:

- a home consome `data/tarefas.json`
- em modo local (`file://`), a home deve ter espelhos `.js` para os dados dinamicos, como `data/tarefas.js`, `data/materias_provas.js` e `data/unidades_materias.js`
- a home nunca deve ler o Google Calendar diretamente no navegador
- a logica da agenda da home fica em `home-agenda.js`
- `home-agenda.js` pode corrigir textos com mojibake antes da renderizacao
- `Proximas provas` e `Eventos e avisos` devem continuar lado a lado em telas maiores, sem um painel externo adicional
- evitar containers externos desnecessarios na home quando isso criar camadas visuais demais, especialmente no celular

## Regras Da Agenda

A agenda deve separar os itens em:

- `tarefa`
- `prova`
- `evento`
- `aviso`

Regras de exibicao:

- `Tarefas de hoje` mostra apenas tarefas com vencimento no dia atual
- `Tarefas de amanha` mostra apenas tarefas com vencimento no dia seguinte
- `Proximos prazos` mostra tarefas com `urgencia` `esta_semana` ou `proximos_dias`
- `Proximas provas` mostra apenas itens classificados como `prova`
- `Eventos e avisos` mostra eventos institucionais e comunicados gerais
- os cards da agenda devem usar resumo compacto por padrao e abrir `Ver detalhes` apenas quando houver texto longo ou descricao adicional
- cards de `Proximas provas` podem exibir o botao `Materia da prova` quando houver conteudo complementar cadastrado
- a materia da prova deve vir de um arquivo separado do calendario, para permitir complemento manual com base no Google Sala de Aula

## Regras Da Contagem De Unidades

- a home deve contar automaticamente quantas unidades de conteudo existem em cada pagina de materia
- a contagem deve considerar os botoes `.tab-btn` que nao tenham `data-home-ignore="true"`
- abas como `Quiz` e `Resumo` devem sempre usar `data-home-ignore="true"`
- novas paginas devem seguir essa regra desde a criacao para que a home nao precise de ajustes manuais

## Regras De Prazo Das Tarefas

- se o professor informar uma data explicita no texto, essa data deve ser usada como prazo
- se a mesma mensagem trouxer duas ou mais datas explicitas, a agenda deve duplicar a tarefa para cada data encontrada, mantendo a mensagem completa em todas elas
- nao tentar separar manualmente qual trecho pertence a qual data quando o professor misturar tudo no mesmo texto; repetir o conteudo integral em cada prazo e a regra oficial
- se o professor escrever `amanha`, o prazo deve ser o dia seguinte ao evento
- se o professor escrever `hoje`, o prazo deve ser o mesmo dia do evento
- se nao houver prazo explicito, a tarefa deve vencer no proximo dia letivo
- se a tarefa for lancada na sexta-feira sem prazo explicito, ela deve vencer na segunda-feira

## Regras De Classificacao Do Calendario

- eventos institucionais nao devem entrar em `Proximos prazos` so porque o texto contem palavras como `livro`, `leitura` ou `atividade`
- feiras, recessos, celebracoes e avisos gerais devem ser classificados como `evento`
- exemplos de eventos institucionais que devem ir para `Eventos e avisos`:
  - `FELITROCA`
  - `Felicita`
  - recessos
  - Quinta-Feira Santa
  - Sexta-Feira Santa
- quando o contexto for institucional, a materia deve preferir `Geral`
- o contexto de materia deve refletir a intencao escolar real, e nao apenas palavras soltas encontradas na descricao

Mapeamento oficial das siglas do calendario:

- `HIST` = `Historia`
- `LP` = `Portugues`
- `MAT` = `Matematica`
- `PeC` = `Pensamento Computacional`
- `EMO` = `Emocionar`
- `PLIC` = `Projeto de Leitura`
- `RED` = `Redacao`
- `E. REL.` = `Ensino Religioso`
- `CIEN` = `Ciencias`
- `ENG` = `Ingles`
- `GEO` = `Geografia`

Regras oficiais de tipo no calendario:

- tudo que aparecer como `Miniteste`, `Prova` ou `2a Chamada` deve ser tratado como `prova`
- tudo que aparecer como `FELITROCA`, `STEAM`, `FELICITA`, `RECESSO ESCOLAR`, `FERIADO`, `HOMENAGEM`, `VOLTA AS AULAS`, `EXPOSICAO` e equivalentes deve ser tratado como `evento`
- para `evento` e `aviso`, exibir somente o titulo, sem transformar a descricao longa em titulo
- ao identificar a materia, priorizar a sigla e o resumo original do evento antes de palavras soltas no corpo da descricao

## Regras De Exibicao Das Tarefas

- para `tarefa`, o titulo exibido deve preservar o texto completo relevante do professor
- nao cortar informacoes importantes como:
  - `Casa, lista 7`
  - `trazer o livro e o caderno`
- paginas, folhas e orientacoes de entrega
- se o texto completo ficar maior, ainda assim a informacao importante deve ser preservada

## Materia Da Prova

- o calendario informa a existencia da prova e sua data
- o detalhamento da materia da prova deve ser salvo em `data/materias_provas.json`
- deve existir um espelho `data/materias_provas.js` para a home funcionar tambem quando aberta direto do arquivo local
- esse arquivo deve ser preenchido manualmente a partir do que os professores publicarem no Google Sala de Aula
- cada item deve ser associado a uma prova por `titulo_prova`, `materia` e `data`
- quando houver conteudo cadastrado, a home deve mostrar o botao `Materia da prova` no card da prova
- o conteudo deve seguir um padrao limpo e consistente, sem emojis
- padronizar os itens como lista objetiva, com frases curtas
- quando houver observacao importante, registrar como ultimo item da lista

## Sincronizacao Automatica

- o sincronizador oficial do calendario e `scripts/sync_calendar.ps1`
- o arquivo de saida oficial e `data/tarefas.json`
- o workflow oficial de automacao e `.github/workflows/sync-calendar.yml`
- o GitHub Actions deve:
  - rodar automaticamente uma vez por hora
  - permitir execucao manual por `workflow_dispatch`
  - commitar apenas quando `data/tarefas.json` mudar
- a automacao deve usar o fuso `America/Sao_Paulo` para manter coerencia com os prazos da turma

## Padrao Dos Cards De Conteudo

Os cards didaticos seguem uma logica visual consistente:

- titulos curtos e fortes
- explicacao breve
- exemplos destacados
- blocos separados por tema
- combinacao de cards coloridos e cards brancos de apoio

Evitar:

- blocos de texto longos demais
- conteudo corrido sem respiro visual
- excesso de subtopicos dentro do mesmo card

## Padrao Do Quiz

Os quizzes atuais compartilham caracteristicas que devem ser mantidas:

- pergunta central visivel e destacada
- progresso visivel
- placar de acertos
- opcoes em botoes grandes
- feedback imediato apos resposta
- estado final com mensagem motivadora
- bloco de revisao dos erros

Ao ajustar ou criar quiz:

- preservar linguagem simples e encorajadora
- manter feedback curto e util
- evitar interfaces mais complexas do que o necessario
- manter coerencia com o nivel do 4o ano

## Padrao Do Resumo E Impressao

Os resumos para impressao tambem seguem um padrao:

- bloco de controles primeiro
- preview na tela depois
- area de impressao separada e oculta
- titulos claros
- hierarquia forte entre `h2` e `h3`
- conteudo organizado para leitura rapida e revisao

Ao atualizar essa area:

- manter o preview legivel na tela
- nao quebrar o layout de impressao
- preservar textos curtos, listas e blocos objetivos

## Regras De Manutencao E Padronizacao

- antes de criar um novo padrao visual, verificar se ja existe um padrao equivalente em outra materia
- preferir evolucao consistente ao inves de redesign isolado
- reutilizar classes, nomes e estruturas quando isso nao gerar acoplamento desnecessario
- se uma pagina nova exigir excecao, ela deve ainda parecer parte do mesmo projeto
- nao misturar estilos muito diferentes entre disciplinas sem uma razao clara
- em mudancas pequenas, preservar a identidade visual ja existente
- em mudancas de conteudo, priorizar consistencia editorial e visual ao mesmo tempo
- o padrao oficial de menu e o de Historia: abas em faixa horizontal rolavel, sem quebra de linha
- novas paginas com muitas abas devem seguir esse mesmo modelo por padrao, inclusive para tablet
- em telas pequenas, o botao `Home` deve continuar visivel sem empurrar o titulo para baixo: preferir versao compacta, fixa e com alto contraste, em vez de coloca-lo no fluxo acima do header

## Servidor Local

- o arquivo `python.py` existe para facilitar a visualizacao local da home via servidor simples
- o modo mais confiavel de validacao local deve ser abrir um PowerShell na raiz do projeto e rodar `python .\python.py`
- se `python` nao estiver disponivel no terminal, tentar `py .\python.py`
- depois abrir `http://127.0.0.1:8000`
- preferir esse fluxo local do usuario em vez de depender de servidores improvisados do ambiente do agente
- esse servidor local deve ser usado sempre que for necessario validar a home, a agenda ou qualquer comportamento que dependa de carregamento de arquivos locais

## O Que Evitar

- resumos genericos desconectados do que a escola cobra
- conteudo correto, mas fora do nivel da turma
- excesso de informacao que atrapalhe a memorizacao
- mudancas de layout ou arquitetura sem necessidade clara
- alteracoes fora do escopo pedido
