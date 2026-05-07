# Pagali Wallet — Documentação para Apresentação
## CPV IIPS Mojaloop Hackathon 2026

---

## SLIDE 1 — Título

**Pagali Wallet**
*"Pague ali" — A infraestrutura de pagamentos inclusiva de Cabo Verde*

- Plataforma open-source baseada em **Mojaloop**
- 10 casos de uso implementados
- App Flutter (iOS + Android) + Dashboard regulatório BCV
- Linda Peixoto · Pagali · linda.peixoto@pagali.cv

---

## SLIDE 2 — O Problema

**Cabo Verde hoje:**

| Problema | Dado |
|---|---|
| População sem conta bancária | ~30% dos 560.000 habitantes |
| Remessas da diáspora | ~150M€/ano · **20% do PIB** |
| Taxa actual nas remessas | 8-12% (Western Union, MoneyGram) |
| Comerciantes sem pagamento digital | ~60% |
| Ilhas sem agência bancária | Santo Antão, São Nicolau, Fogo |
| Pagamento de impostos | 70% ainda em papel/presencial |

**O BCV hoje é um regulador com binóculos — vê os bancos mas não vê o dinheiro.**

---

## SLIDE 3 — A Solução

**Pagali = Pagamentos Inclusivos para Cabo Verde**

*"Pague ali"* em Crioulo cabo-verdiano.

**O que é:**
- Wallet digital para qualquer pessoa com telemóvel
- Conecta todos os bancos num único ecossistema interoperável
- Baseado no padrão global **Mojaloop Foundation** (Gates Foundation, Google)
- Licença **Apache 2.0** — open-source, custo zero de licença

**O que resolve:**
- Qualquer pessoa envia dinheiro entre bancos diferentes
- Um QR code serve todos os comerciantes de todos os bancos
- O governo distribui subsídios em segundos
- A diáspora envia remessas com taxa de 1.5%

---

## SLIDE 4 — Arquitectura do Sistema

```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────────────┐
│  App Flutter    │    │  Core Connector  │    │    Mojaloop Hub         │
│  iOS + Android  │◄──►│  Node.js :8030   │◄──►│  (produção: K8s)        │
└─────────────────┘    └──────────────────┘    └─────────────────────────┘
                               │
              ┌────────────────┼────────────────┐
              │                │                │
    ┌─────────────┐  ┌─────────────────┐  ┌────────────┐
    │ QR Service  │  │Merchant Registry│  │  Settlement│
    │  :8031      │  │    :4002        │  │   Engine   │
    └─────────────┘  └─────────────────┘  └────────────┘
```

**Protocolo:** FSPIOP API — padrão Mojaloop (3 fases)
1. **Discovery** — localizar o beneficiário (ALS)
2. **Agreement** — negociar taxas e condições (Quote)
3. **Transfer** — executar a transferência (Central Ledger)

**FSPs participantes:** BCVCVCV (Banco Comercial do Atlântico) · BCNCV (Banco Caboverdiano de Negócios)

---

## SLIDE 5 — Use Case 1: P2P — Transferência entre Pessoas

**O que é:** Transferência de dinheiro entre dois telemóveis de bancos diferentes.

**Fluxo:**
1. Ana (BCVCVCV) abre a app → selecciona João (BCNCV)
2. Insere 1.000 CVE → vê taxa de 5,00 CVE (0.5%)
3. Confirma → João recebe instantaneamente

**Identificação:** Número de telemóvel (MSISDN)
**Taxa:** 0,5% do montante
**Tempo:** < 3 segundos

**Impacto:** Elimina as transferências bancárias que demoram 2-3 dias úteis entre bancos.

---

## SLIDE 6 — Use Case 2: P2M — Pagamento a Comerciante por QR

**O que é:** Cliente paga ao comerciante com QR code — sem hardware, sem POS.

**Padrão:** EMVCo TLV (mesmo standard que Tailândia, Singapura, Quénia)

**Estrutura do QR Pagali:**
```
DFSP Swift Code (routing) → BCVCVCV
Merchant ID               → MER001
Merchant Category Code    → 5411 (supermercado)
Moeda                     → 132 (CVE)
Assinatura RSA-SHA256     → anti-fraude
```

**Fluxo:**
1. Comerciante mostra QR na app → cliente aponta câmara
2. App identifica Mercado Sucupira, Praia · MCC 5411 · Verificado
3. Cliente insere montante → confirma → comerciante recebe notificação

**Impacto:** Um QR único serve qualquer banco — sem caixas múltiplas.

---

## SLIDE 7 — Use Case 3: G2P — Governo para Pessoa

**O que é:** O governo distribui subsídios directamente no telemóvel dos beneficiários.

**Fluxo:**
1. Governo faz upload da lista de beneficiários (MSISDN + montante)
2. Sistema processa cada beneficiário automaticamente via Mojaloop
3. Cada pessoa recebe o dinheiro em segundos — sem fila, sem papel

**Dados de demo:**
- Programa: *Subsídio Social — Maio 2026*
- 4 beneficiários · 5.000 CVE cada · Total: 20.000 CVE
- Processamento: ~3 segundos por beneficiário

**Impacto:**
- Elimina deslocações a gabinetes do governo
- Rastreabilidade total — auditoria em tempo real
- Chega a ilhas sem banco através de agentes

---

## SLIDE 8 — Use Case 4: FX — Remessas Internacionais

**O que é:** A diáspora envia dinheiro para Cabo Verde em moeda estrangeira.

**Moedas suportadas:**
| Moeda | Taxa | Diáspora |
|---|---|---|
| EUR | 110.265 CVE (fixo) | Portugal, França |
| USD | ~102 CVE | EUA, Holanda |
| GBP | ~130 CVE | Reino Unido |
| BRL | ~18 CVE | Brasil |

**Exemplo:**
- Emigrante em Lisboa envia 100 EUR
- Taxa Pagali: 1,5% (vs 8-12% Western Union)
- Família recebe: 10.852 CVE em segundos

**Impacto:**
- Poupança de ~95M€/ano para as famílias cabo-verdianas (se toda a diáspora usar Pagali)

---

## SLIDE 9 — Use Case 5: R2P — Request to Pay

**O que é:** O comerciante envia um pedido de pagamento ao cliente — sem QR, sem hardware.

**Fluxo:**
1. Restaurante Sodade envia pedido: *"Refeição · 850 CVE"* para o MSISDN do cliente
2. Cliente recebe notificação na app Pagali
3. Vê o pedido com nome do restaurante, montante e descrição
4. Toca **Aprovar** → pagamento executado instantaneamente

**Quando usar:**
- Restaurantes (comanda digital)
- Encomendas por WhatsApp
- Serviços ao domicílio (canalização, electricidade)
- Pagamentos recorrentes (ginásio, escola)

---

## SLIDE 10 — Use Case 6: Agent Banking

**O que é:** Agentes humanos nas ilhas sem banco fazem cash-in e cash-out.

**Rede de Agentes Pagali:**
| Agente | Ilha | Float |
|---|---|---|
| Loja Nha Filomena | Santo Antão · Porto Novo | 50.000 CVE |
| Mercadinho do Zé | São Nicolau · Ribeira Brava | 30.000 CVE |
| Taberna da Bela | Fogo · São Filipe | 45.000 CVE |

**Fluxo Cash-In:**
1. Pessoa entrega 5.000 CVE em dinheiro ao agente
2. Agente faz cash-in na app → wallet do cliente creditada
3. Taxa: 50 CVE fixo

**Impacto:** Inclusão financeira real — chega onde não há banco físico.

---

## SLIDE 11 — Use Case 7: Pagamento de Impostos

**O que é:** Cidadão paga impostos directamente na app, sem ir a um serviço público.

**Impostos disponíveis:**
| Código | Nome | Taxa |
|---|---|---|
| IGT | Imposto s/ Rendimento Singular | 15% |
| INPS | Previdência Social | 8,5% |
| IVA | Imposto s/ Valor Acrescentado | 15% |
| IUP | Imposto s/ Património | 0,8% |
| IUR | Imposto s/ Rendimento Empresas | 25% |

**Fluxo:**
1. Selecciona tipo de imposto → insere NIF e base tributável
2. Sistema calcula automaticamente o montante
3. Confirma → recibo digital emitido instantaneamente

**Impacto:** Digitalização do cumprimento fiscal — de 30% para potencialmente 90%.

---

## SLIDE 12 — Use Case 8: CBDC — Escudo Digital

**O que é:** Versão digital do Escudo Cabo-verdiano emitida directamente pelo BCV.

**Características:**
- **Emitido por:** Banco de Cabo Verde (autoridade única)
- **Paridade:** 1 ₠ = 1 CVE (fixo, garantido pelo BCV)
- **Conversão:** Instantânea CVE ↔ ₠ sem custo
- **Transferência:** Entre carteiras CBDC em tempo real

**O que o BCV pode fazer:**
- Emitir Escudo Digital directamente (mint)
- Controlar a circulação total em tempo real
- Implementar política monetária digital
- Programar pagamentos condicionais (ex: subsídios com restrição de uso)

**Posição de Cabo Verde:** BCV já tem projecto piloto de CBDC — Pagali é a infraestrutura de distribuição.

---

## SLIDE 13 — Use Case 9: TopUp — Carregar Saldo

**O que é:** Carregar a wallet Pagali através de diferentes métodos.

**Métodos disponíveis:**
| Método | Como funciona | Mojaloop? |
|---|---|---|
| Agente Pagali | Cash-in via agente humano | ✅ Sim |
| Transferência bancária | Banco envia via Mojaloop | ✅ Sim |
| Cartão | Crédito directo | Fase 2 |

**Montantes sugeridos:** 1.000 · 2.500 · 5.000 · 10.000 CVE

---

## SLIDE 14 — Use Case 10: PISP — Iniciação de Pagamentos por Terceiros

**O que é:** Apps de terceiros (e-commerce, imobiliário, turismo) iniciam pagamentos em nome do utilizador — com o seu consentimento prévio.

**Baseado em:** Mojaloop Third Party API (TPAPI)

**Fluxo:**
1. Utilizador autoriza "Loja Online CV" com limite de 10.000 CVE / 30 dias
2. Utilizador faz compra na Loja Online CV
3. App envia pedido via API Pagali → utilizador recebe notificação
4. Toca **Aprovar** → pagamento executado · saldo debitado

**Apps integradas (demo):**
- 🛒 Loja Online CV (e-commerce)
- 🏠 Renda CV (imobiliário)
- ✈️ Turismo Cabo Verde (viagens)

**Impacto:** Qualquer app pode integrar pagamentos sem construir a sua própria infraestrutura bancária.

---

## SLIDE 15 — Dashboard BCV Regulador

**O BCV como Scheme Operator tem visibilidade total:**

### Operações em Tempo Real
- Volume total transaccionado (CVE)
- Breakdown por tipo: P2P · P2M · G2P · FX · R2P · Agent · Tax · CBDC · PISP
- Gráfico de volume por tipo + linha temporal

### Controlo Regulatório
- **NDC por FSP** — Net Debit Cap com barra de utilização e alertas
- **Janelas de Liquidação** — OPEN/CLOSED/SETTLED com botão de encerramento
- **Matriz Interbancária** — fluxo BCVCVCV ↔ BCNCV com posição líquida
- **Export CSV/JSON** — relatório completo para auditoria

### PISP & Consentimentos
- Pedidos de iniciação pendentes/aprovados/rejeitados
- Rastreabilidade de consentimentos por app terceira

**Acesso:** `http://[servidor]:8030` → tab BCV Regulador

---

## SLIDE 16 — Por Que o BCV Escolhe Pagali?

| Argumento | Impacto |
|---|---|
| **100% controlo regulatório** | BCV vê e controla cada transação em tempo real |
| **~30% sem conta bancária** | Agent Banking chega a Santo Antão, São Nicolau, Fogo |
| **~150M€/ano em remessas** | Taxa de 1,5% em vez de 8-12% |
| **₠ CBDC** | BCV emite Escudo Digital directamente |
| **0€ licença** | Open-source Apache 2.0 · padrão global Mojaloop |
| **10 Use Cases** | Sistema completo — não apenas P2P |

> *"O BCV hoje é um regulador com binóculos. Com Pagali, torna-se o operador da infraestrutura nacional de pagamentos de Cabo Verde."*

---

## SLIDE 17 — Stack Tecnológico

| Camada | Tecnologia | Função |
|---|---|---|
| App Mobile | Flutter / Dart 3.11 | iOS + Android |
| Core Connector | Node.js + Express | FSPIOP API |
| QR Standard | EMVCo TLV + CRC-16 | Interoperabilidade |
| Protocolo | FSPIOP (Mojaloop) | 3 fases: Discovery/Quote/Transfer |
| Settlement | Net Deferred + NDC | Liquidação interbancária |
| CBDC | Escudo Digital (BCV) | Moeda digital soberana |
| FX | EUR/USD/GBP/BRL → CVE | Remessas |
| Licença | Apache 2.0 | Open-source gratuito |

**Repositório:** https://github.com/ISONE-DEVOPS/Pagali-wallet

---

## SLIDE 18 — Roadmap para Produção (Piloto BCV)

### Fase 1 — Piloto (3 meses)
- [ ] Ligar ao sdk-scheme-adapter real (Mojaloop Hub)
- [ ] mTLS + JWS signing (segurança por certificado)
- [ ] MCM — Mojaloop Connection Manager
- [ ] Base de dados real (MySQL/Percona) em vez de memória
- [ ] Onboarding dos 2 FSPs: BCVCVCV + BCNCV

### Fase 2 — Expansão (6 meses)
- [ ] Kafka — event streaming assíncrono
- [ ] HSM — Hardware Security Module
- [ ] Certificação Mojaloop oficial
- [ ] Mais FSPs (MFIs, cooperativas, MNOs)
- [ ] Push notifications reais (FCM)
- [ ] KYC digital (BI + selfie)

### Fase 3 — Nacional (12 meses)
- [ ] Todos os bancos e operadoras de Cabo Verde
- [ ] CBDC em produção com BCV
- [ ] Integração com IGT e INPS (impostos automáticos)
- [ ] Open Banking / API pública para terceiros

---

## SLIDE 19 — Resumo dos 10 Use Cases

| # | Use Case | Quem beneficia | Status |
|---|---|---|---|
| 1 | **P2P** Transferências | Toda a população | ✅ Funcional |
| 2 | **P2M** QR Comerciante | Comerciantes + clientes | ✅ Funcional |
| 3 | **G2P** Subsídios | Governo + beneficiários | ✅ Funcional |
| 4 | **FX** Remessas | Diáspora + famílias | ✅ Funcional |
| 5 | **R2P** Request to Pay | Comerciantes | ✅ Funcional |
| 6 | **Agent Banking** | Ilhas sem banco | ✅ Funcional |
| 7 | **Impostos** | Cidadãos + IGT/INPS | ✅ Funcional |
| 8 | **CBDC** Escudo Digital | BCV + utilizadores | ✅ Funcional |
| 9 | **TopUp** Carregar Saldo | Todos | ✅ Funcional |
| 10 | **PISP** Iniciação | Apps terceiras | ✅ Funcional |

---

## SLIDE 20 — Demo ao Vivo

**Para demonstrar (sequência recomendada):**

1. **Splash** → onboarding → login demo (1 clique)
2. **Home** — saldo 5.320,00 CVE · 4 quick actions · Mais Serviços
3. **P2P** — Enviar 1.000 CVE a João Monteiro → confirmar → sucesso
4. **P2M** — Pagar QR → Simular QR → Mercado Sucupira → 500 CVE → sucesso
5. **G2P** — Distribuir subsídios → 4 beneficiários a mudar para "Pago" em tempo real
6. **FX** — 100 EUR → 10.852 CVE para Ana Silva → sucesso
7. **Dashboard** → mostrar todas as transações ao júri em tempo real
8. **BCV Regulador** → NDC · settlement · matriz interbancária · export CSV

**URL Dashboard:** `http://localhost:8030`

---

## SLIDE 21 — Call to Action

**Pagali está pronto para ser o piloto nacional.**

O que pedimos ao BCV:
1. Seleccionar Pagali como projecto piloto IIPS
2. Onboarding dos primeiros 2 FSPs (BCVCVCV + BCNCV)
3. Acesso ao ambiente Mojaloop Hub para ligação real
4. Parceria para lançamento do Escudo Digital (CBDC)

**Contacto:**
Linda Peixoto · Pagali
linda.peixoto@pagali.cv
GitHub: github.com/ISONE-DEVOPS/Pagali-wallet

> *"Com Pagali, qualquer pessoa em Cabo Verde — de Santo Antão a Boa Vista — paga, recebe e poupa. Com um telemóvel. Com qualquer banco. Com segurança."*

---

## ANEXO — Endpoints da API

### Core Connector (:8030)
```
P2P/P2M:  GET /parties/MSISDN/:msisdn · POST /transfers · POST /transfers/:id/accept-quote
G2P:      POST /g2p/batches · GET /g2p/batches/:id
FX:       GET /fx/rates · POST /fx/quote · POST /fx/transfers
R2P:      POST /requests · POST /requests/:id/accept
Agents:   GET /agents · POST /agents/:id/cash-in · POST /agents/:id/cash-out
Tax:      GET /tax/types · POST /tax/calculate · POST /tax/pay
CBDC:     GET /cbdc/wallet/:msisdn · POST /cbdc/mint · POST /cbdc/convert/to-cbdc
PISP:     POST /pisp/consents · POST /pisp/initiate · POST /pisp/initiations/:id/approve
Settlement: GET /settlement/positions · GET /settlement/windows · GET /settlement/report.csv
```

### Merchant Registry (:4002)
```
GET  /merchants · GET /merchants/:id
POST /payments/notify · GET /payments/:merchantId
```

### QR Service (:8031)
```
POST /qr/generate  (EMVCo TLV + CRC-16)
POST /qr/parse     (validação + extracção)
```
