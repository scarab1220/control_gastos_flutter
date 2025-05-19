# 💰 Control de Gastos Personales – Flutter App

Aplicación móvil desarrollada en Flutter que permite registrar, filtrar, visualizar y exportar gastos personales, con persistencia local mediante SQLite.

---

## 📲 Funcionalidades principales

- Agregar, editar y eliminar gastos
- Filtro por categoría y mes
- Gráfico de pastel con resumen por categoría (`fl_chart`)
- Alerta si se supera un límite mensual definido por el usuario
- Exportación de gastos a CSV para compartir o analizar
- Interfaz moderna y responsiva

---

## 📁 Estructura del proyecto

```bash
lib/
├── database/           # Manejo de SQLite (DatabaseHelper)
├── models/             # Modelo Gasto
├── screens/            # Pantallas: inicio, formulario, estadísticas
├── utils/              # Funciones auxiliares: límite mensual
└── main.dart           # Entrada principal
