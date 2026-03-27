# AGENTS.md

## Objetivo Deste Projeto

Este projeto existe para apoiar o estudo de crianças do 4º ano por meio de flashcards, quizzes e materiais de revisão. O foco principal não é produzir conteúdo escolar genérico, mas sim criar materiais alinhados ao contexto real em que a escola ensina e cobra as avaliações.

## Princípio Central

Todo conteúdo novo deve partir primeiro do material real da escola.

Isso inclui, quando disponível:

- matéria da prova
- roteiros enviados pelos professores
- exercícios
- páginas do livro
- tarefas de casa
- resumos usados em sala
- listas, folhas e exemplos já trabalhados com a turma

Conhecimento geral pode ser usado para complementar, organizar e esclarecer, mas nunca deve substituir o contexto escolar como fonte principal de decisão.

## Como Trabalhar Neste Repositório

Ao receber novo conteúdo ou uma nova tarefa, seguir esta ordem:

1. Entender o que a escola realmente está cobrando.
2. Identificar o vocabulário, o recorte e o nível de dificuldade usados pela turma.
3. Separar o que é conteúdo essencial, o que é detalhe cobrável e o que é só complemento.
4. Montar flashcards, quizzes e resumos com base nesse recorte.
5. Manter a linguagem apropriada para crianças do 4º ano.

## Regras De Conteúdo

- Priorizar aderência ao material da escola acima de abrangência.
- Evitar expandir demais para assuntos fora do escopo da prova.
- Preservar, sempre que possível, a terminologia usada pelo professor e pelo material didático.
- Preferir exemplos parecidos com os vistos em sala, no livro ou nas tarefas.
- Não transformar o conteúdo em algo mais difícil do que a escola espera.
- Não simplificar tanto a ponto de perder o formato em que o conteúdo costuma ser cobrado.

## Regras De Produção

- Trabalhar por tarefa e dentro de escopo definido.
- Antes de publicar alterações, sempre apresentar um resumo claro do que foi mudado.
- Usar branch por tarefa.
- Fluxo enxuto acordado:
  - criar ou usar uma branch da tarefa
  - fazer as alterações dentro do escopo
  - mostrar um resumo claro do que mudou
  - com uma única aprovação do usuário, fazer commit, push e merge

## Fluxo De Publicação No GitHub

O fluxo padrão deste projeto para envio ao GitHub é:

1. criar uma branch por tarefa
2. realizar apenas as alterações do escopo pedido
3. apresentar ao usuário um resumo objetivo das mudanças
4. após uma única aprovação do usuário, executar:
   - commit
   - push da branch
   - merge na `main`

## Regras De Publicação

- Não fazer commit sem resumo prévio.
- Não publicar alterações fora do escopo pedido.
- Não abrir novas frentes de mudança no meio da tarefa sem alinhamento.
- Preferir merge simples e direto quando o usuário aprovar a publicação.
- Se houver bloqueio técnico no fluxo de publicação, explicar claramente o que faltou e em qual etapa.

## Regras Para Novos Materiais

Quando o usuário enviar novo conteúdo da escola, o agente deve:

1. Primeiro interpretar e organizar o material.
2. Depois propor a estrutura ideal de estudo, quando isso ajudar.
3. Só então transformar o conteúdo em páginas, flashcards, quiz ou resumo.

## Organização Atual Do Projeto

O projeto é um site estático simples, sem build e sem backend.

Estrutura atual:

- `index.html` como página inicial e hub das matérias
- uma página HTML por disciplina
- estilos e scripts inline em cada página
- pasta `imagens/` para imagens didáticas locais

Cada página de matéria é autônoma e costuma reunir no mesmo arquivo:

- estrutura HTML
- CSS da página
- conteúdo didático
- lógica das abas
- lógica do quiz
- área de resumo para impressão

## Padrão Estrutural Das Páginas De Matéria

Ao criar novas páginas ou expandir páginas existentes, preservar o padrão já usado:

- botão de volta para a home no topo
- `header` escuro com título e subtítulo da matéria
- navegação por abas com botões arredondados
- seções com `.section` e alternância por classe `.active`
- blocos de conteúdo em cards
- área separada para quiz
- área separada para resumo/impressão

Fluxo visual esperado dentro de uma página:

1. identificação da matéria no topo
2. navegação por abas
3. conteúdo principal em cards e blocos didáticos
4. quiz com feedback imediato
5. revisão final
6. resumo para impressão

## Componentes Visuais Que Devem Permanecer Consistentes

Manter a linguagem visual já estabelecida:

- cantos arredondados generosos, geralmente entre `20px` e `24px`
- cards com sombra sólida vertical, não sombra difusa fraca
- cores fortes e lúdicas, sem aparência corporativa
- tipografia principal com `Nunito`
- títulos e destaques com `Fredoka One`
- botões em formato pílula
- badges e chips arredondados
- uso frequente de grids responsivos para cards

Padrões recorrentes que devem ser preservados:

- `.btn-home`
- `header` com fundo escuro e textura suave
- `.tabs` e `.tab-btn`
- `.section` e `.section.active`
- `.cards-grid` ou grids equivalentes
- `.dica-card`
- `.quiz-shell`
- `.resultado-shell`
- `.resumo-controles`
- `.resumo-preview`

## Padrão De Cores

Existe uma base visual comum entre as matérias:

- fundo geral claro
- topo com fundo escuro `#1A1A2E`
- amarelo de destaque recorrente `#FFD93D`
- paleta viva com laranja, verde, azul, rosa e roxo

Cada matéria usa uma cor principal própria para criar identidade:

- Português: azul, roxo e laranja
- Ciências: verde e turquesa
- Matemática: laranja, azul e marrom
- Geografia: verdes e azuis
- História: marrom, vermelho e azul terroso

Regras de uso:

- manter alto contraste entre texto e fundo
- preservar a cor principal da matéria em abas ativas, badges e destaques
- usar branco para superfícies internas de quiz, resultado e resumo
- evitar reinventar a paleta completa a cada atualização pequena
- não introduzir temas visuais que destoem da linguagem infantil já existente

## Padrão Da Home

A home tem um papel específico e deve continuar simples:

- apresentar as matérias como cards grandes clicáveis
- usar uma grade responsiva
- mostrar nome da matéria, descrição curta e chips de disponibilidade
- manter um card de "Em breve" quando fizer sentido
- preservar o header com identidade do projeto e o aviso no rodapé

Ao adicionar novas matérias:

- seguir o mesmo formato dos cards existentes
- definir uma cor própria para a matéria
- manter descrição curta e uniforme
- usar textos curtos nos chips

## Padrão Dos Cards De Conteúdo

Os cards didáticos seguem uma lógica visual consistente:

- títulos curtos e fortes
- explicação breve
- exemplos destacados
- blocos separados por tema
- combinação de cards coloridos e cards brancos de apoio

Evitar:

- blocos de texto longos demais
- conteúdo corrido sem respiro visual
- excesso de subtópicos dentro do mesmo card

## Padrão Do Quiz

Os quizzes atuais compartilham características que devem ser mantidas:

- pergunta central visível e destacada
- progresso visível
- placar de acertos
- opções em botões grandes
- feedback imediato após resposta
- estado final com mensagem motivadora
- bloco de revisão dos erros

Ao ajustar ou criar quiz:

- preservar linguagem simples e encorajadora
- manter feedback curto e útil
- evitar interfaces mais complexas do que o necessário
- manter coerência com o nível do 4º ano

## Padrão Do Resumo E Impressão

Os resumos para impressão também seguem um padrão:

- bloco de controles primeiro
- preview na tela depois
- área de impressão separada e oculta
- títulos claros
- hierarquia forte entre `h2` e `h3`
- conteúdo organizado para leitura rápida e revisão

Ao atualizar essa área:

- manter o preview legível na tela
- não quebrar o layout de impressão
- preservar textos curtos, listas e blocos objetivos

## Regras De Manutenção E Padronização

- Antes de criar um novo padrão visual, verificar se já existe um padrão equivalente em outra matéria.
- Preferir evolução consistente ao invés de redesign isolado.
- Reutilizar classes, nomes e estruturas quando isso não gerar acoplamento desnecessário.
- Se uma página nova exigir exceção, ela deve ainda parecer parte do mesmo projeto.
- Não misturar estilos muito diferentes entre disciplinas sem uma razão clara.
- Em mudanças pequenas, preservar a identidade visual já existente.
- Em mudanças de conteúdo, priorizar consistência editorial e visual ao mesmo tempo.

## O Que Evitar

- Resumos genéricos desconectados do que a escola cobra.
- Conteúdo correto, mas fora do nível da turma.
- Excesso de informação que atrapalhe a memorização.
- Mudanças de layout ou arquitetura sem necessidade clara.
- Alterações fora do escopo pedido.
