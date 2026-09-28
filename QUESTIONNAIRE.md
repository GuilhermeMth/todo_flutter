# Questionnaire — Mobile To-Do App

Este questionário resume as decisões, a implementação e a validação do aplicativo conforme documentado em [BUILD_LOG.md](./BUILD_LOG.md).

## 1. Qual arquitetura foi utilizada?

Foi utilizada uma arquitetura simples baseada em serviços e telas Flutter nativas. Os modelos `Task` e `Category`, o serviço `TodoDatabase`, o serviço `NotificationService` e as três telas principais estão organizados em `lib/main.dart`.

A solução evita complexidade desnecessária para um aplicativo educacional pequeno.

## 2. Qual estratégia de gerenciamento de estado foi escolhida?

O estado é gerenciado localmente por `StatefulWidget` nas telas. Após operações assíncronas de criação, edição, exclusão, conclusão, alteração de filtros ou retorno de telas filhas, os dados são recarregados do banco e a interface é atualizada.

Nenhuma biblioteca externa de gerenciamento de estado foi adicionada.

## 3. Como os dados são persistidos?

Foi utilizado SQLite por meio das dependências `sqflite` e `path`.

O banco contém:

- `categories`: `id` e `name`;
- `tasks`: `id`, `title`, `description`, `completed`, `due_date_time`, `created_at` e `category_id`.

A relação entre tarefa e categoria usa chave estrangeira com `ON DELETE SET NULL`. Assim, excluir uma categoria não exclui as tarefas associadas; elas permanecem salvas sem categoria.

## 4. Quais telas foram implementadas?

### Lista de tarefas

Exibe título, estado, categoria e vencimento. Permite:

- criar tarefas;
- abrir tarefas existentes;
- concluir ou reabrir tarefas;
- filtrar por Todas, Pendentes ou Concluídas;
- filtrar por categoria;
- abrir o gerenciamento de categorias.

### Editor/detalhe da tarefa

Permite editar:

- título obrigatório;
- descrição opcional;
- categoria opcional;
- data e hora opcionais;
- estado concluída/pendente.

Também permite salvar, cancelar por navegação e excluir tarefas existentes.

### Gerenciamento de categorias

Permite listar, criar, renomear e excluir categorias.

## 5. Como a navegação foi implementada?

Foi utilizado o `Navigator` padrão do Flutter com `MaterialPageRoute`.

Ao editar uma tarefa, o objeto da tarefa e a lista atual de categorias são passados diretamente para a tela de edição. Ao retornar, a lista principal recarrega os dados do SQLite.

## 6. Como os filtros funcionam?

Os filtros são aplicados em memória sobre a lista carregada do SQLite:

- filtro de status: todas, pendentes ou concluídas;
- filtro de categoria: todas as categorias ou uma categoria específica.

Essa abordagem foi escolhida por ser suficiente e simples para o escopo do aplicativo.

## 7. Como os vencimentos são tratados?

O usuário pode escolher uma data e uma hora futuras. Também pode remover o vencimento posteriormente.

Datas antigas são tratadas sem quebrar o editor: o seletor de data usa o dia atual como limite mínimo, preservando o valor existente no restante do formulário.

## 8. Como as notificações locais funcionam?

Foi utilizada a dependência `flutter_local_notifications`, com `timezone` para converter datas em `TZDateTime`.

O ID da tarefa é usado como ID da notificação. O comportamento é:

- tarefa futura salva: agenda notificação;
- vencimento alterado: cancela a anterior e agenda a nova;
- vencimento removido: cancela a notificação;
- tarefa concluída: cancela a notificação;
- tarefa reaberta com vencimento futuro: pode agendar novamente;
- tarefa excluída: cancela a notificação.

O agendamento Android usa o modo inexato para evitar a necessidade de permissão de alarme exato.

## 9. Como as permissões de notificação são tratadas?

As permissões são solicitadas quando o serviço de notificações é inicializado:

- Android: `POST_NOTIFICATIONS`;
- iOS: permissões de alerta, badge e som;
- macOS: permissões de alerta, badge e som.

Falhas de inicialização ou agendamento são tratadas nos fluxos de persistência e exibidas ao usuário quando aplicável, sem depender de servidor remoto.

## 10. Quais dependências importantes foram adicionadas?

- `sqflite`: banco SQLite local;
- `path`: construção do caminho do arquivo do banco;
- `flutter_local_notifications`: notificações locais;
- `timezone`: datas para notificações agendadas;
- `intl`: formatação de datas e horas.

## 11. Quais validações foram executadas?

As seguintes validações passaram:

- `flutter pub get`;
- `flutter analyze`, sem problemas;
- `flutter test`, com 3 testes aprovados;
- `dart format --output=none --set-exit-if-changed lib test`;
- `xmllint --noout android/app/src/main/AndroidManifest.xml`;
- `flutter build apk --debug`;
- verificação de que o APK gerado existe e não está vazio.

O APK foi gerado em `build/app/outputs/flutter-apk/app-debug.apk`.

## 12. O que os testes automatizados cobrem?

Os testes em `test/main_test.dart` verificam:

- serialização e restauração de todos os campos obrigatórios de uma tarefa;
- omissão correta do ID ao criar uma nova tarefa;
- serialização e restauração de categorias.

## 13. Quais problemas foram encontrados e corrigidos?

- API removida do plugin de notificações: parâmetros obsoletos foram removidos.
- Conflito entre `path.Context` e `BuildContext`: o import de `path` foi prefixado.
- Exigência de core library desugaring: configuração adicionada ao Gradle Android.
- Limites do seletor de datas para tarefas antigas: corrigidos.
- Manifesto Android malformado: atributo `android:name` corrigido.
- Avisos de lint sobre argumentos depreciados e chaves ausentes: corrigidos.
- Ausência inicial do Flutter/Dart: posteriormente o ambiente foi configurado e as validações foram executadas.

## 14. Quais limitações permanecem?

Não havia dispositivo Android ou emulador conectado quando `adb devices` foi executado. Portanto, os seguintes pontos não foram verificados por interação manual em dispositivo:

- instalação e abertura do APK em hardware/emulador;
- persistência após reinício real do aplicativo;
- entrega real de uma notificação agendada;
- fluxos completos de UI em Android.

O `flutter doctor -v` também indicou ausência do Chrome e de dependências para Linux desktop, mas essas limitações não bloqueiam o alvo Android do MVP.

## 15. Qual é o estado final do projeto?

O MVP está implementado, analisado, testado e compilado para Android. O repositório foi publicado em:

<https://github.com/GuilhermeMth/todo_flutter>

O histórico Git foi organizado em ciclos de implementação e validação, conforme registrado em [BUILD_LOG.md](./BUILD_LOG.md).
