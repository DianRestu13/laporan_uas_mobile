// main.typ
#import "conf.typ": project
#import "cover.typ": cover_page

// Data Kelompok (Sesuaikan dengan peran di soal)
#let members_data = (
  (name: "Danish Naisyila Azka", nim: "362458302098", role: "Backend Architect"), // [cite: 23]
  (name: "Dian Restu Khoirunnisa", nim: "362458302094", role: "UI Engineer"),       // [cite: 28]
  (name: "Vina Faizatus Sofita", nim: "362458302094", role: "Auth & Navigation"), // [cite: 33]
  (name: "Nadhifah Afiyah Qurota'ain", nim: "362458302100", role: "Transaction Logic"), // [cite: 37]
)

#show: doc => project(
  title: "Laporan Final Project: Smart E-Kantin",
  semester: "Ganjil 2024/2025",
  team_number: "04",
  members: members_data,
  doc
)

// Generate Cover
#cover_page(
  title: "Laporan Final Project: Smart E-Kantin",
  semester: "Ganjil 2024/2025",
  team_number: "04",
  members: members_data
)

// Include Bab-bab
#include "chapters/bab1.typ"
#include "chapters/bab2.typ"
#include "chapters/bab3.typ"
#include "chapters/bab4.typ"
#include "chapters/bab5.typ"
#include "chapters/bab6.typ"
#include "chapters/bab7.typ"