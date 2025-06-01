# TechCare - Salesforce

Projeto TechCare implementa funcionalidades personalizadas em Apex e Lightning Web Components para o objeto `Case_Request__c`, focando no controle de SLA, fechamento e reabertura de casos.

---

## Features

- **API REST** para consulta de histórico de casos (`CaseHistoryApi`).
- **Triggers e Handlers** para automação no fechamento de casos (`CaseRequestClosedTrigger` e `CaseRequestClosedHandler`).
- **Controlador Apex** para reabertura e atualização de status de casos (`CaseRequestController`).
- **Consulta de duração SLA** via método cacheável (`CaseHistoryController`).

## Apex Classes

### `CaseHistoryApi`  

Classe Apex que expõe um endpoint REST para consultar detalhes de um registro `Case_History__c` específico.

#### Endpoint

- URL: `/services/apexrest/CaseHistory/{caseHistoryId}`
- Método HTTP: `GET`

#### Comportamento

- Recebe um `caseHistoryId` pela URL.
- Busca o registro `Case_History__c` pelo Id informado, retornando o status do caso relacionado (`Case__r.Status__c`) e o campo `SLA_Met__c`.
- Se o registro não existir, retorna erro 404.
- Em caso de erro interno, retorna erro 500.

#### Respostas

- **200 OK**  
  JSON com os detalhes do histórico do caso:

  ```json
  {
  "Status": "Closed",
  "SLA_Met__c": true
  }


### `CaseRequestClosedTrigger`   
Essa Classe é uma trigger que é executada após a atualização do objeto `Case_Request__c`. Detecta quando o status do caso é alterado para `"Closed"` e aciona a classe handler `CaseRequestCloseHandler` responsável pelo processamento do fechamento.

### `CaseRequestClosedHandler`
Classe handler responsável por criar registros de histórico para casos que foram fechados (`Status__c = 'Closed'`). Essa classe calcula se o SLA foi cumprido e registra a duração até o fechamento, criando um registro detalhado no objeto `Case_History__c`.

### `CaseRequestController`  

Classe Apex que expõe métodos para reabrir casos e atualizar o status do objeto `Case_Request__c`. Projetada para ser consumida por componentes Lightning (LWC ou Aura).

#### Métodos

 `@AuraEnabled public static void reopenCase(Id caseId)`  
  Reabre um caso, alterando seu status para `"In Progress"` e atualizando o prazo do SLA (`SLA_Deadline__c`) para 8 horas a partir do momento atual.

  **Parâmetro:**  
   - `caseId`: Id do caso a ser reaberto.

`@AuraEnabled public static void updateStatus(Id recordId, String newStatus)`  
  Atualiza o status de um caso com o novo valor fornecido.

  **Parâmetros:**  
   - `recordId`: Id do registro a ser atualizado.  
   - `newStatus`: Novo status a ser atribuído.

### `CaseHistoryController`  

Classe Apex que expõe método para recuperar a duração do SLA de um caso a partir do objeto `Case_History__c`.

#### Método
  Retorna uma `String` com a duração do SLA no formato armazenado (`ex: "2h 30min"`). Criada para ser consumida no componente lwc

- `@AuraEnabled(cacheable=true) public static String getSlaDuration(Id caseRequestId)`  
  Retorna a duração do SLA (`SLA_Duration__c`).

  **Parâmetro:**  
  - `caseRequestId`: Id do registro `Case_Request__c` para o qual se deseja obter a duração do SLA.
 
  
## LWC Components

### `caseRequestDetail` - 
Componente LWC para exibir o prazo do SLA (`SLA_Deadline__c`) de um registro `Case_Request__c` e permitir a reabertura do caso quando fechado.

#### Funcionalidades

- Exibe um timer dinâmico mostrando o tempo restante para o SLA expirar.
- Exibe a duração do SLA após o fechamento do caso.
- Botão para reabrir o caso quando o status estiver como `"Closed"`.
- Atualiza a interface após reabertura com toast notification.

#### Integração com Apex

Este componente consome métodos Apex para controle do SLA e reabertura do caso:

| Método Apex                       | Classe Apex                 | Função                                                       |
|----------------------------------|----------------------------|-------------------------------------------------------------|
| `reopenCase(Id caseId)`           | `CaseRequestController`    | Reabre o caso, atualizando status e prazo do SLA.           |
| `getSlaDuration(Id caseRequestId)`| `CaseHistoryController`    | Retorna a duração do SLA para exibição no componente.       |

---

## Instruções de Deploy

1. Importe as classes Apex:  
   - `CaseHistoryApi`  
   - `CaseRequestClosedTrigger`  
   - `CaseRequestClosedHandler`  
   - `CaseRequestController`  
   - `CaseHistoryController`  
   - Classes de teste

2. Importe e faça deploy do componente LWC `caseRequestDetail`.

3. Configure a página Lightning para adicionar o componente `caseRequestDetail` na visualização do objeto `Case_Request__c`.

4. Execute os testes unitários para garantir cobertura superior a 90%.


