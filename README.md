# Oficina na Nuvem 🔧☁️

Aplicativo Flutter de gestão para oficinas mecânicas — e para os clientes delas.
Duas experiências no mesmo app, decididas pelo papel da conta no login:

- **Cliente**: cadastra seus veículos (carro, moto, caminhão, utilitário, jet ski
  e até aeronave), acompanha status, aciona o socorro 24h.
- **Oficina**: dashboard com indicadores, ordens de serviço com fluxo de status,
  catálogo de serviços por categoria, equipe de funcionários.

> Todo o backend é simulado por mocks em memória — a arquitetura foi desenhada
> para trocar cada mock por uma API real alterando um único arquivo.

## Funcionalidades

### Área do cliente
- Cadastro de conta com validação de CPF, telefone (DDDs reais) e e-mail
- Endereço por CEP (ViaCEP) com política de retry e fallback manual
- Onboarding de veículos com dados da Tabela FIPE (marca → modelo → ano
  pesquisáveis); tipos fora da FIPE (jet ski, aeronave) com preenchimento manual
- Home com garagem, ações rápidas e status dos veículos

### Área da oficina
- Cadastro com CNPJ **alfanumérico** (nova regra da Receita Federal)
- Dashboard: OS abertas, faturamento, gráfico semanal, ordens recentes
- Ordens de serviço: abertura vinculando cliente + veículo + serviços do
  catálogo, filtros por status (em andamento, testes, aguardando aprovação,
  aprovada) e mudança de status no detalhe
- Catálogo de serviços com categorias, preço e desconto máximo
- Gestão de funcionários (CRUD completo)

## Arquitetura

MVVM por feature, com separação estrita de camadas e SOLID:

```
lib/
├── core/            # tema (design tokens), widgets, DI, validadores,
│                    # máscaras, retry policy, navegação
├── shared/          # blocos reutilizáveis entre features (ex.: endereço/CEP)
└── features/
    └── <feature>/
        ├── models/
        ├── data/
        │   ├── services/      # interface abstrata + implementação mock
        │   └── repositories/  # dependem só das interfaces (DIP)
        └── presentation/
            ├── view_models/   # ChangeNotifier, estado como ViewState selado
            ├── pages/
            └── widgets/
```

- **Composition root** em `core/di/app_dependencies.dart`: único lugar que
  conhece as implementações mock.
- **`ViewState<T>` selado** (loading/success/failure): estados inválidos são
  irrepresentáveis, e o `switch` exaustivo garante tratamento em toda tela.
- **Design tokens** em `core/theme/` espelham o arquivo de design
  (`design_oficina_nuvem.pen`, editado no Pencil).

## Rodando

```bash
flutter pub get
flutter run
```

Contas de demonstração (mock):

| Papel   | E-mail                   | Senha        |
| ------- | ------------------------ | ------------ |
| Oficina | `ti@oficinanuvem.com.br` | `oficina123` |
| Cliente | `cliente@email.com`      | `cliente123` |

Ou crie uma conta nova — o cadastro de cliente passa pelo onboarding de
veículos antes de chegar à home.

## Qualidade

```bash
flutter analyze   # zero issues
flutter test      # ~100 testes: unitários (validadores, retry, FIPE)
                  # e de widget (fluxos completos de cadastro, OS, garagem)
```

## Build

```bash
flutter build apk --release
```

> O release ainda assina com a chave de debug (sem keystore no repositório).
> Configure sua própria em `android/key.properties` antes de distribuir.

## Roadmap

- [ ] Backend real (substituir os mocks pelas APIs)
- [ ] Agendamento de serviços pelo cliente
- [ ] Aprovação de orçamento pelo cliente no app
- [ ] Notificações de status da OS
