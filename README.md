# Descrição breve da solução

### O que é o Azure Pipelines?
- A Entrega Contínua (CD) é um processo pelo qual o código é compilado,
testado e implantado em um ou mais ambientes de teste e produção
- A implantação e o teste em vários ambientes melhora a qualidade
- implantados, incluindo infraestrutura e aplicativos.
- Os Processos de Releases Automatizados consomem esses artefatos para liberar novas versões ou correções para os sistemas existentes
- Os sistemas de Monitoramento e Alerta são executados continuamente para melhorar a visibilidade de todo o processo de CD
![alt text](image-1.png)
--

# Passo a Passo:
- Criar e utilizar a VM Free no portal do Azure
- Se conectar ao SSH da VM Linux e portar o arquivo ".sh":

Abra o terminal (ou PowerShell no Windows) e digite o seguinte comando para conectar à sua VM:
```
ssh <usuário>@<endereço_ip>
scp /caminho/local/do/arquivo.sh <usuário>@<endereço_ip>:<diretório_destino>

```
- Concender permissões de execução ao arquivo .sh
```
chmod +x meu_arquivo.sh
``` 



---

### O que a aplicação faz
API .NET (ASP.NET Core Web API) que expõe endpoints para gerenciar recursos do Mottu (ex.: Pátio, Cliente e Moto). A API usa MySQL Express como banco de dados.

### Stack tecnológica

Backend: .NET 8 — ASP.NET Core Web API

Banco de dados: Azure Database for MySQL (PaaS).

Container registry: Azure Container Registry (ACR)

CI/CD: Azure DevOps Pipelines (YAML) conectados ao repositório GitHub

Infra / deploy: Azure Web App for Containers ou Azure Container Instances (ACI) (usaremos Web App for Containers no exemplo)

Autenticação/Secrets: Azure DevOps Library (secure variables) ou Service Connections


---

# Arquitetura + Fluxo CI/CD (diagrama)

Diagrama feito para demonstrar o Fluxo CI/CD 
- Para analisar a Arquitetura
![alt text](image.png)


---

## Requisitos - Sprint 4
```bash

| Nome do componente                | Tipo                    | Descrição funcional                                                                 | Tecnologia / Ferramenta                         |
|-----------------------------------|-------------------------:|-------------------------------------------------------------------------------------|-------------------------------------------------|
| Repositório de código (SCM)       | Git (hosted)            | Código-fonte da aplicação e pipelines (YAML)                                       | GitHub (https://github.com/christianmilfont/...) |
| Pipeline / Orquestrador CI        | CI/CD                   | Compila, executa testes unitários, publica artefato e gera imagem Docker           | Azure DevOps Pipelines (YAML multi-stage)      |
| Registry de Imagens               | Container Registry      | Armazena imagem Docker utilizada no deploy                                         | Docker Hub (ou GitHub Container Registry / ACR)|
| Build Agent                       | Runner                  | Executa jobs de build/test/push                                                     | Azure DevOps Hosted Agents                      |
| Artifact Storage                  | Artifact                | Publicação do build para acionar release                                           | Azure DevOps Artifacts                          |
| Ambiente de Execução (Prod)       | PaaS / Web App          | Hospeda a API dentro de container Docker                                            | Azure Web App for Containers                    |
| Banco de Dados (Produção)         | PaaS - RDBMS            | Banco MySQL gerenciado (produção)                                                  | Azure Database for MySQL (Single Server/Pas)    |
| Secret Management                  | Variáveis protegidas    | Armazenamento de strings de conexão, usuários, senhas e chaves de serviço          | Azure DevOps Library (Variable groups - secret) |
| Infra as Code (opcional)          | IaC                     | Provisionamento automatizado dos recursos (opcional)                               | ARM Templates / Bicep / Terraform               |
| Monitoramento / Logging (recomend)| Observability           | Logs e métricas (opcional)                                                          | Azure Monitor / Application Insights (opcional) |

```

---

Regras da Pipeline (obrigatórias no enunciado) — como atendemos:
I. Pipeline conectado ao GitHub: configure Webhook/Service connection no pipeline.
II. CI disparando a cada alteração na master: trigger: branches: include: - master.
III. CD disparar após novo artefato gerado: multi-stage com stage Deploy que depende do Build/Publish.
IV. Variáveis protegidas: usar Variable Groups e marcar secrets.
V. Gerar e publicar artefato: publish: $(Build.ArtifactStagingDirectory)/app.zip.
VI. Execução de testes: dotnet test no stage de CI.
VII. Deploy com imagem Docker no Azure Web App for Containers (o YAML irá buildar a imagem, push ao Docker Hub e atualizar o Web App com a imagem).
