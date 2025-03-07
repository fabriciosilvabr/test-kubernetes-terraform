# 🚀 Teste Técnico DevOps: Helm e Terraform (AWS)

Este repositório contém uma solução completa para o teste técnico envolvendo criação de infraestrutura na AWS com Terraform e deploy de uma aplicação Nginx em Kubernetes usando Helm.

---

## 📌 Pré-requisitos obrigatórios:

- Terraform instalado localmente.
- AWS CLI configurado localmente (com credenciais).
- Helm instalado localmente.

---

## ⚙️ Infraestrutura criada:

- Instância EC2 (Ubuntu 22.04 LTS).
- Chave SSH gerada automaticamente pelo Terraform.
- Security Group com portas 22 (SSH) e 80 (HTTP) liberadas.
- Instalação automática de Docker, Kind, Kubectl e Helm.

---

## 🚧 Criando a infraestrutura com Terraform

### 1. Clone este repositório:

```bash
git clone https://github.com/fabriciosilvabr/test-kubernetes-terraform.git
cd test-kubernetes-terraform
```

### 2. Inicialize e aplique o Terraform:

```bash
terraform init
terraform plan
terraform apply
```

Confirme digitando `yes` quando solicitado.

---

## 🔑 Acessando a instância criada

Após o Terraform concluir, utilize a chave gerada automaticamente para acessar a instância EC2:

```bash
ssh -i terraform-generated-key.pem ubuntu@<IP_PUBLICO_EC2>
```

> O IP público estará disponível como saída do comando Terraform.

---

## 📦 Deploy da aplicação com Helm (Kubernetes)

### Copie o Helm Chart do seu computador local para a EC2:

```bash
scp -i terraform-generated-key.pem -r ../helm-chart ubuntu@<IP_PUBLICO_EC2>:/home/ubuntu/
```

### Dentro da instância EC2, faça o deploy:

```bash
cd ~/helm-chart
helm install meu-nginx .
```

### Verifique o deploy no Kubernetes (Kind):

```bash
kubectl get pods,svc
```

---

## 🌐 Acessando o Nginx externamente

Para acessar o Nginx pelo navegador, realize o port-forward na EC2:

```bash
kubectl port-forward svc/meu-nginx 80:80 --address=0.0.0.0
```

Em seguida, abra seu navegador e acesse:

```
http://<IP_PUBLICO_EC2>
```

Você deverá visualizar a página padrão do Nginx.

---

## 🧹 Limpeza após o teste (opcional)

Para destruir os recursos criados pelo Terraform:

```bash
terraform destroy
```

Confirme digitando `yes` quando solicitado.

---

## 🎯 Considerações Finais

- Este teste técnico demonstra automação completa desde a criação da infraestrutura até o deploy da aplicação.
- O Helm Chart é configurado de forma genérica e parametrizável, seguindo boas práticas.
- Terraform garante automação, segurança e reprodutibilidade do ambiente.

---
