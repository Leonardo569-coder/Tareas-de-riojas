# 📘 Tarea 1.1: Conceptos Fundamentales, Mapa Conceptual y Modelos de Bases de Datos

## 👤 Datos de Identificación

* **Nombre:** Leonardo Martinez Salinas
* **Matrícula:** I24050412
* **Maestro:** Ruben Riojas
* **Asignatura:** Fundamentos de Bases de Datos
* **Unidad:** [Unidad 1 — Introducción a las Bases de Datos](../)

---

## 📑 Descripción

En esta actividad se investigan y estructuran los fundamentos teóricos de los Sistemas de Gestión de Bases de Datos (SGBD / DBMS). El documento desarrolla tres apartados centrales:

1. **Planteamiento e Investigación de Conceptos Fundamentales:** Definición formal de base de datos y SGBD, abordando sus objetivos principales (independencia física y lógica de los datos, control de redundancia e inconsistencia, integridad y validación, seguridad y control de acceso, concurrencia y transaccionalidad ACID, y recuperación ante fallos) así como sus usos y áreas de aplicación (Sector Salud/Hospitalario ECE, Banca y Finanzas, Comercio Electrónico/Retail y Educación).
2. **Mapa Conceptual Analítico de Bases de Datos:** Representación jerárquica de los objetivos, modelos de datos y áreas de aplicación.
3. **Tabla Comparativa de Modelos de Bases de Datos:** Evaluación de los modelos Jerárquico, en Red, Relacional, OODBMS, ORDBMS y NoSQL bajo los criterios de definición, representación, ventajas y limitaciones.

---

## 📊 Visualización de Gráficos

### 1. Mapa Conceptual Analítico de Bases de Datos (Mermaid.js)

```mermaid
graph TD
    Root["SISTEMA DE BASES DE DATOS"]

    Root --> B1["1. Objetivos Principales"]
    Root --> B2["2. Modelos de Datos"]
    Root --> B3["3. Areas de Aplicacion"]

    B1 --> O1["Independencia de Datos<br>Aislamiento entre Nivel Fisico y Logico"]
    B1 --> O2["Control de Redundancia<br>Eliminacion de Duplicidad e Inconsistencias"]
    B1 --> O3["Integridad y Seguridad<br>Reglas de Dominio y Control por Roles"]
    B1 --> O4["Transacciones ACID<br>Atomicidad, Consistencia, Aislamiento, Durabilidad"]

    B2 --> M1["Pre-relacionales<br>Jerarquico: Arbol / Red: Grafo CODASYL"]
    B2 --> M2["Relacional RDBMS<br>Tablas, Tuplas, Claves PK/FK y SQL"]
    B2 --> M3["Orientado a Objetos / Hibridos<br>Clases, Metodos, OODBMS y ORDBMS"]
    B2 --> M4["NoSQL y Multiparadigma<br>Documentos JSON, Clave-Valor, Grafos"]

    B3 --> A1["Sector Salud<br>Sistemas HIS y Expedientes Clinicos ECE"]
    B3 --> A2["Banca y Finanzas<br>Procesamiento Transaccional en Tiempo Real"]
    B3 --> A3["E-Commerce y Logistica<br>Control de Inventarios, Pedidos y Clientes"]
    B3 --> A4["Educacion y Gobierno<br>Control Escolar y Registros Ciudadanos"]
```

---

### 2. Tabla Comparativa de Modelos de Bases de Datos

| Modelo | Definición | Representación | Ventajas | Limitaciones |
| :--- | :--- | :--- | :--- | :--- |
| **Modelo Jerárquico** | Organización en árbol de padre e hijos. | Estructura de Árbol con punteros. | Alta velocidad para consultas simples. | Rigidez, redundancia y sin relaciones N:M directas. |
| **Modelo en Red** | Evolución CODASYL con múltiples padres por hijo. | Grafo/Red con conjuntos (sets). | Permite N:M y reduce redundancia. | Complejidad en navegación y mantenimiento. |
| **Modelo Relacional** | Basado en teoría de conjuntos de E.F. Codd. | Tablas (Filas/Tuplas, Columnas). | Independencia de datos y lenguaje SQL. | Rendimiento menor en uniones complejas. |
| **Modelo OODBMS** | Integra paradigma POO en almacenamiento. | Objetos, Clases, Métodos, Herencia. | Maneja datos complejos (multimedia/CAD). | Falta de estándar universal equivalente a SQL. |
| **Modelo ORDBMS** | Híbrido entre relacional y POO. | Tablas relacionales con tipos complejos. | Combina SQL con flexibilidad de objetos. | Mayor sobrecarga y complejidad conceptual. |
| **Modelo NoSQL** | Optimizado para Big Data y esquemas flexibles. | Documentos (JSON), Clave-Valor, Grafos. | Alta escalabilidad horizontal y flexibilidad. | Sacrifica ACID estricto por disponibilidad (BASE). |

---

## 📚 Referencias Bibliográficas

* Codd, E. F. (1970). A relational model of data for large shared data banks. *Communications of the ACM*, 13(6), 377–387.
* Date, C. J. (2004). *An introduction to database systems* (8.ª ed.). Pearson Education.
* Elmasri, R., & Navathe, S. B. (2017). *Fundamentos de sistemas de bases de datos* (7.ª ed.). Pearson Educación.
* Silberschatz, A., Korth, H. F., & Sudarshan, S. (2020). *Database system concepts* (7.ª ed.). McGraw-Hill Education.

---

## 📦 Entregables

* 📄 **Archivo PDF de la Actividad:** [Tarea_1.1.pdf](./Tarea_1.1.pdf)
* 📹 **Video Explicativo en YouTube:** [Ver video en YouTube](https://youtu.be/88zoZEnNuKI)
