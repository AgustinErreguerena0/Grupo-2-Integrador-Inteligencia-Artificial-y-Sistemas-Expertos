# 🧭 Proyecto de Navegación y Algoritmos de Búsqueda
### Trabajo Integrador – Inteligencia Artificial y Sistemas Expertos

**Integrantes:**
- Erreguerena Agustín Iñaki  
- Piloni Fabrizio Julián  

---

## 📝 Descripción General

Este proyecto es un videojuego educativo desarrollado como trabajo integrador para la materia *Inteligencia Artificial y Sistemas Expertos*.  
El objetivo principal es visualizar y comprender cómo funcionan distintos algoritmos de búsqueda dentro de un entorno interactivo basado en una grilla.

Además, el proyecto nos permitió explorar el desarrollo básico de videojuegos utilizando **Godot Engine**, un motor gratuito y open source. La industria del desarrollo de videojuegos es una de las más grandes dentro del desarrollo de software, pero no se aborda en la carrera de Licenciatura en Sistemas de Información, por lo que este trabajo fue una buena oportunidad para aprender sus fundamentos.

---

## 🎮 Objetivo del Juego

El juego permite observar paso a paso cómo distintos algoritmos encuentran un camino desde un punto inicial hasta un objetivo en una grilla con obstáculos.  
El usuario puede analizar:

- La manera en que cada algoritmo explora el mapa.  
- Cuáles nodos son visitados y en qué orden.   
- El impacto de permitir o no movimientos diagonales.  

---

## 🔍 Algoritmos Implementados

### 🔹 Algoritmos Informados (A\*)
A\* se implementó con las siguientes heurísticas:

- **Distancia Manhattan**  
- **Distancia Euclidiana**  
- **Distancia Chebyshev**  
- **Distancia Octile**

Cada heurística puede configurarse para permitir o no **movimientos diagonales**.

### 🔹 Algoritmos No Informados
Se implementaron también:

- **Búsqueda en Amplitud (BFS)**  
- **Búsqueda en Profundidad (DFS)**  

Estos permiten comparar los enfoques ciegos frente al algoritmo A\*.

---

## 🕹️ Tecnologías Utilizadas

- Motor: **Godot Engine**  
- Lenguaje: **GDScript**  
- Plataforma: **PC**  
- Proyecto base proveniente del repositorio oficial de Godot  

---

## 📦 Base del Proyecto

Por cuestiones de tiempo y para lograr un mayor alcance, el proyecto se desarrolló tomando como base un ejemplo del repositorio oficial de Godot, el cual contenía una implementación inicial del algoritmo A\*.  
A partir de este punto, se agregaron nuevas funciones, algoritmos y adaptaciones para cumplir los objetivos del trabajo.

Repositorio base utilizado:  
https://github.com/godotengine/godot-demo-projects

---

## ⚖️ Licencia

El proyecto base se encuentra bajo la **Licencia MIT**, la cual permite:

- Usar  
- Copiar  
- Modificar  
- Publicar  
- Distribuir  
- Sublicenciar  
- Vender copias del software  

Siempre que se mantenga el aviso de derechos de autor y el aviso de permiso.  
Este repositorio respeta dichas condiciones.

---

## 🚀 Cómo Ejecutar el Proyecto

1. Descargar o clonar este repositorio.  
2. Abrir **Godot Engine** (versión compatible con el proyecto).  
3. Importar la carpeta del proyecto desde la interfaz de Godot.  
4. Ejecutar la escena principal.

---

## 🎯 Conclusión

Este trabajo permitió estudiar algoritmos de búsqueda desde una perspectiva práctica y visual, además de introducirnos al desarrollo de videojuegos utilizando herramientas reales de la industria. Representa una unión entre conceptos de inteligencia artificial y un entorno interactivo que facilita su comprensión.

---
