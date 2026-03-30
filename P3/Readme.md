# 📡 Projet P3 – Architecture Réseau Multi-Branches (GNS3 + Docker)

## 🎯 Objectif

Ce projet consiste à mettre en place une **architecture réseau multi-branches** en utilisant **GNS3 et Docker**, avec une configuration automatisée :

* d’un **routeur central (gateway)**
* de plusieurs **routeurs de branches**
* de plusieurs **hôtes**
* avec une **connectivité complète entre tous les réseaux**

L’objectif est de simuler une infrastructure réseau réaliste et scalable.

---

## 🧱 Architecture

```
                (Gateway)
              _moouahab-1
          ┌────────┼────────┐
          │        │        │
     Branch1   Branch2   Branch3
   (_-2)      (_-3)      (_-4)
      │          │          │
   Host1      Host2      Host3
```

---

## 🌐 Plan d’adressage

| Équipement | Interface | Adresse IP      |
| ---------- | --------- | --------------- |
| Gateway    | eth0      | 10.0.1.1/24     |
|            | eth1      | 10.0.2.1/24     |
|            | eth2      | 10.0.3.1/24     |
| Branche 1  | eth0      | 10.0.1.2/24     |
|            | eth1      | 192.168.1.1/24  |
| Branche 2  | eth0      | 10.0.2.2/24     |
|            | eth1      | 192.168.2.1/24  |
| Branche 3  | eth0      | 10.0.3.2/24     |
|            | eth1      | 192.168.3.1/24  |
| Hosts      | eth0      | 192.168.X.10/24 |

---

## ⚙️ Fonctionnalités

* 🔁 Routage statique entre tous les réseaux
* 🔄 Activation de l’IP forwarding
* ⚡ Déploiement automatisé via scripts
* 📦 Infrastructure conteneurisée (Docker)
* 🔧 Architecture scalable (ajout de branches)

---

## 🚀 Déploiement

### 1. Lancer le projet GNS3

```bash
docker ps
```

---

### 2. Configurer le gateway

```bash
make gateway
```

---

### 3. Configurer les branches

```bash
make branches
```

Chaque routeur de branche reçoit :

* une IP backbone (`10.0.X.2`)
* un réseau local (`192.168.X.1`)
* une route par défaut vers le gateway

---

### 4. Configurer les hosts

```bash
make hosts
```

Chaque host reçoit :

* IP : `192.168.X.10`
* Gateway : `192.168.X.1`

---

### 5. Tester la connectivité

```bash
make test
```

Résultat attendu :

* ✅ Host1 → Host2
* ✅ Host1 → Host3

---

## 🔍 Troubleshooting

### ❌ "RTNETLINK: File exists"

→ La route existe déjà (pas bloquant)

---

### ❌ Problème de ping entre réseaux

#### 1. Vérifier les routes du gateway

```bash
ip route
```

Doit contenir :

```
192.168.1.0/24 via 10.0.1.2
192.168.2.0/24 via 10.0.2.2
192.168.3.0/24 via 10.0.3.2
```

---

#### 2. Vérifier l’IP forwarding

```bash
cat /proc/sys/net/ipv4/ip_forward
```

Doit être :

```
1
```

---

#### 3. Vérifier la connectivité réseau (GNS3)

```bash
ping 10.0.X.1
```

Si ça échoue :

👉 ce n’est PAS un problème de routage
👉 c’est un problème de **liaison (Layer 2)**

✔ Vérifier :

* les câbles dans GNS3
* les interfaces (eth0 / eth1 / eth2)

---

## 🧠 Concepts clés

* Routage statique
* Différence Layer 2 / Layer 3
* Isolation réseau Docker
* Routage multi-interfaces
* Automatisation d’infrastructure

---

## 📈 Scalabilité

Le script :

```bash
set_branch.sh
```

permet :

* d’ajouter N branches
* d’automatiser l’adressage IP
* de réutiliser l’architecture

---

## 🏁 Conclusion

Ce projet démontre :

* une bonne maîtrise des réseaux
* une capacité de debug réelle (niveau terrain)
* des compétences en automatisation
* une approche proche des environnements SOC

---

## 👤 Auteur

Mohamed Ouahab
Cybersécurité / DevSecOps / SOC

