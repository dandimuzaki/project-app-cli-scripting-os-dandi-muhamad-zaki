#!/bin/bash

# Deklarasi variabel
jenis_tanaman=("selada" "pakcoy" "tomat" "cabai" "timun")
banyak_jenis=${#jenis_tanaman[@]}
declare -A kebun
declare -A keranjang

# Definisi warna
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

# Fungsi untuk menampilkan jenis-jenis tanaman yang dapat ditanam
daftar_tanaman() {
  echo -e "${PURPLE}Daftar Tanaman${NC}"
  for (( i=0; i<${banyak_jenis}; i++ )); do
    echo "$((i+1)). ${jenis_tanaman[${i}]}"
  done
}

# Fungsi untuk menghitung banyaknya tanaman di kebun yang siap dipanen
hitung_panen() {
  sum=0
  for key in "${!kebun[@]}"; do
    if ((${kebun[${key}]} == 5)); then
      (( sum++ ))
    fi
  done
  return $sum
}

# Fungsi untuk menampilkan jenis-jenis tanaman yang sudah ditanam di kebun dan masing-masing level penyiramannya
lihat_kebun() {
  echo -e "\n${GREEN}Kebunmu${NC}"
  echo "---------------------------"
  echo "tanaman     level_siram    "
  for key in "${!kebun[@]}"; do
    echo "${key}         ${kebun[${key}]}"
  done
  echo "---------------------------"
  hitung_panen
  panen=$?
  if (( panen > 0)); then
    echo -e "${BLUE}Kamu punya ${panen} tanaman yang siap dipanen!${NC}"
  fi
}

# Fungsi untuk menghitungnya banyaknya sayuran yang sudah dipanen
hitung_keranjang() {
  count=0
  for key in "${!keranjang[@]}"; do
    (( count+=keranjang[${key}] ))
  done
  return $count
}

# Fungsi untuk menampilkan daftar hasil panen beserta kuantitasnya
lihat_keranjang() {
  hitung_keranjang
  banyak_keranjang=$?

  echo -e "\n${PURPLE}Keranjang Hasil Panenmu${NC}"
  echo "---------------------------"
  echo "tanaman     kuantitas    "
  for key in "${!keranjang[@]}"; do
    echo "${key}         ${keranjang[${key}]}"
  done
  echo "---------------------------"
  if (( banyak_keranjang <=0 )); then
    echo -e "${YELLOW}Keranjangmu masih kosong nih!${NC}"
  else
    echo -e "${BLUE}Selamat kamu punya ${banyak_keranjang} sayur yang siap dimakan!${NC}"
  fi
  while true; do
    read -p "Kembali ke menu? (y): " next
    if [[ $next == "y" ]]; then
      break
    else
      echo -e "${RED}[GAGAL] Input tidak valid! Silakan coba lagi.${NC}"
      continue
    fi
  done
}

# Fungsi untuk memvalidasi apakah input nama tanaman ada di daftar tanaman di Toko Tanaman Lumoshive
cari_tanaman() {
  local tanaman=$1
  ketemu=0
  for i in "${jenis_tanaman[@]}"; do
    if [[ $tanaman == "${i}" ]]; then
      ketemu=1
      break
    fi
  done
  return $ketemu
}

# Fungsi untuk menanam tanaman di kebun 
tanam() {
  local tanaman=$1
  cari_tanaman "${tanaman}"
  ketemu=$?
  if (($ketemu == 1)); then
    if  [[ -z "${kebun["${tanaman}"]}" ]]; then
      echo -e "${GREEN}[BERHASIL] Kamu berhasil menanam ${tanaman} di kebun kamu${NC}"
      kebun["${tanaman}"]=0
    else
      echo -e "${YELLOW}[PERINGATAN] Kamu sudah menanam ${tanaman} di kebun kamu${NC}"
    fi
  else
    echo -e "${YELLOW}[PERINGATAN] Kamu tidak bisa menanam ${tanaman} karena tidak ada benihnya :(${NC}"
  fi
}

# Fungsi untuk menyiram tanaman di kebun
siram() {
  local tanaman=$1
  cari_tanaman "${tanaman}"
  ketemu=$?
  if (($ketemu == 1)); then
    if  [[ -z "${kebun["${tanaman}"]}" ]]; then
      echo -e "${RED}[GAGAL] Tidak bisa menyiram! Kamu belum menanam ${tanaman} di kebun kamu${NC}"
    elif (( kebun["${tanaman}"] >=5 )); then
      echo -e "${BLUE}Tanaman ${tanaman} sudah siap dipanen${NC}"
    else
      echo -e "${GREEN}[BERHASIL] Kamu berhasil menyiram ${tanaman} di kebun kamu${NC}"
      ((kebun["${tanaman}"]++))
    fi
  else
    echo -e "${YELLOW}[PERINGATAN] Kamu tidak bisa menyiram ${tanaman} karena tidak ada benih dan tanamannya :(${NC}"
  fi
}

# Fungsi untuk memanen tanaman di kebun
panen() {
  local tanaman=$1
  cari_tanaman "${tanaman}"
  ketemu=$?
  if (($ketemu == 1)); then
    if  [[ -z "${kebun["${tanaman}"]}" ]]; then
      echo -e "${RED}[GAGAL] Tidak bisa memanen! Kamu belum menanam ${tanaman} di kebun kamu\e[0m"
    elif (( kebun["${tanaman}"] == 5 )); then
      unset kebun["${tanaman}"]
      (( keranjang[${tanaman}]++ ))
      echo -e "${GREEN}[BERHASIL] Tanaman ${tanaman} sudah berhasil dipanen${NC}"
    else
      echo -e "${YELLOW}[PERINGATAN] Tanaman ${tanaman} belum siap dipanen${NC}"
    fi
  else
    echo -e "${YELLOW}[PERINGATAN] Kamu tidak bisa memanen ${tanaman} karena tidak ada benih dan tanamannya :(${NC}"
  fi
}

# Fungsi untuk mendapatkan input tanam dari user
opsi_tanam() {
  next="y"
  daftar_tanaman
  while [[ $next == "y" ]]; do
    read -p "Ketikkan nama tanaman yang ingin kamu tanam: " tanaman
    tanam $tanaman
    while true; do
      read -p "Mau menanam lagi? (y/n): " next
      if [[ $next == "y" ]]; then
        break
      elif [[ $next == "n" ]]; then
        break
      else
        echo -e "${RED}[GAGAL] Input tidak valid! Silakan coba lagi.${NC}"
        continue
      fi
    done
  done
}

# Fungsi untuk mendapatkan input siram dari user
opsi_siram() {
  next="y"
  lihat_kebun
  while [[ $next == "y" ]]; do
    read -p "Ketikkan nama tanaman yang ingin kamu siram: " tanaman
    siram $tanaman
    while true; do
      read -p "Mau menyiram lagi? (y/n): " next
      if [[ $next == "y" ]]; then
        break
      elif [[ $next == "n" ]]; then
        break
      else
        echo -e "${RED}[GAGAL] Input tidak valid! Silakan coba lagi.${NC}"
        continue
      fi
    done
  done
}

# Fungsi untuk mendapatkan input panen dari user
opsi_panen() {
  next="y"
  lihat_kebun
  while [[ $next == "y" ]]; do
    read -p "Ketikkan nama tanaman yang ingin kamu panen: " tanaman
    panen $tanaman
    while true; do
      read -p "Mau panen lagi? (y/n): " next
      if [[ $next == "y" ]]; then
        break
      elif [[ $next == "n" ]]; then
        break
      else
        echo -e "${RED}[GAGAL] Input tidak valid! Silakan coba lagi.${NC}"
        continue
      fi
    done
  done
}

# Menu utama
exit=0
while (( $exit==0 )); do
  echo -e "Selamat datang di ${YELLOW}Toko Tanaman Lumoshive!${NC}\n\nLumoshive menjual berbagai jenis tanaman yang bisa ditanam di kebunmu!\nTanam dan siram hingga level 5 agar kamu bisa memanen tanamanmu!"
  daftar_tanaman
  while true; do
    lihat_kebun
    if (( ${#kebun[@]} == 0 )); then
      echo "Kebunmu masih kosong! Yuk mulai menanam."
    fi
    echo -e "\nBeberapa hal yang bisa dilakukan:\n${GREEN}1. tanam${NC}   ${BLUE}2. siram${NC}   ${YELLOW}3. panen${NC}   ${PURPLE}4. lihat keranjang panen${NC}   ${RED}5. keluar${NC}"
    read -p "Pilih aksi (1-5): " action
    if [[ $action == "1" ]]; then
      opsi_tanam
    elif [[ $action == "2" ]]; then
      if (( ${#kebun[@]} == 0 )); then
        echo -e "${RED}[GAGAL] Belum bisa menyiram! Kebunmu masih kosong.${NC}"
        continue
      else
        opsi_siram
      fi
    elif [[ $action == "3" ]]; then
      if (( ${#kebun[@]} == 0 )); then
        echo -e "${RED}[GAGAL] Belum bisa panen! Kebunmu masih kosong.${NC}"
        continue
      else
        opsi_panen
      fi
    elif [[ $action == "4" ]]; then
      lihat_keranjang
    elif [[ $action == "5" ]]; then
      echo -e "${CYAN}Terima kasih sudah berkebun bersama Lumoshive!${NC}"
      exit=1
      break
    else
      echo -e "${RED}[GAGAL] Input tidak valid! Silakan coba lagi.${NC}"
      continue
    fi
  done
done
