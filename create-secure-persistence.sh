#!/bin/bash
# TechNews365 OS Essentials Portable - Script de création de persistance chiffrée LUKS
# Auteur : Jean (TechNews365 OS)

echo "=== TechNews365 OS - Création de la persistance chiffrée LUKS ==="

# Vérification root
if [ "$EUID" -ne 0 ]; then
    echo "Erreur : ce script doit être exécuté en root."
    exit 1
fi

# Sélection du disque
lsblk
echo ""
read -p "Entrez le chemin du disque USB (ex: /dev/sdb) : " DISK

echo ""
echo "ATTENTION : Toutes les données sur $DISK3 seront chiffrées."
read -p "Continuer ? (o/n) : " CONFIRM

if [ "$CONFIRM" != "o" ]; then
    echo "Opération annulée."
    exit 1
fi

# Création de la partition de persistance
echo "Création de la partition de persistance..."
parted $DISK mkpart primary ext4 100% 100%

# Trouver la nouvelle partition
PART="${DISK}3"

echo "Partition créée : $PART"

# Chiffrement LUKS
echo "Initialisation du chiffrement LUKS..."
cryptsetup luksFormat $PART

echo "Ouverture de la partition chiffrée..."
cryptsetup open $PART persistence

echo "Formatage en ext4..."
mkfs.ext4 /dev/mapper/persistence

echo "Montage..."
mkdir -p /mnt/persistence
mount /dev/mapper/persistence /mnt/persistence

echo "Activation de la persistance..."
echo "/ union" > /mnt/persistence/persistence.conf

echo "Démontage..."
umount /mnt/persistence
cryptsetup close persistence

echo ""
echo "=== Persistance chiffrée LUKS créée avec succès ! ==="
echo "Votre clé USB TechNews365 Essentials Portable est maintenant sécurisée."
