# 🖼️ Art Analytics

> Analyse how style, rarity, nationality and other factors influence the market value of famous paintings using **MySQL** and **Python**.

## Table of Contents

1. [Overview](#overview)
2. [Quick Start](#quick-start)
3. [Repository Layout](#repository-layout)
4. [Requirements](#requirements)
5. [Analysis Workflow](#analysis-workflow)
6. [Findings Preview](#findings-preview)
7. [Roadmap](#roadmap)
8. [Contributing](#contributing)
9. [License](#license)
10. [Acknowledgements](#acknowledgements)

---

## Overview

This project loads a **famous\_paintings** relational database and puts six economic hypotheses to the test:

| # | Hypothesis                        | Short description                                                                   |
| - | --------------------------------- | ----------------------------------------------------------------------------------- |
| 1 | **The Value of Style**            | Certain art movements (e.g. Classicism, Cubism) systematically fetch higher prices. |
| 2 | **The Value of Rarity**           | Scarce styles command a premium over saturated ones.                                |
| 3 | **The Nationality Premium**       | Does an artist’s nationality influence price within the same movement?              |
| 4 | \*\*Size Matters \*\****(todo)*** | Are larger canvases worth more?                                                     |
| 5 | **Scarcity & Lifespan**           | Shorter-lived artists may generate scarcity and higher prices.                      |
| 6 | **Subject Matter & Price**        | Some themes (e.g. biblical scenes) outperform others.                               |

The heavy lifting happens in:

- `sql/sql-database.sql` – sets up the schema, loads data, and declares window‑function queries for each hypothesis.
- `notebooks/famous_art_data_visualizations.ipynb` – runs the queries, cleans the output with `pandas`, and visualises results with `matplotlib`/`seaborn`.

---

## About Brushline Analytics

Brushline Analytics is the data‑science studio behind this repository. Our mission is **smarter art investing through data**: we turn historical auction records into actionable signals for collectors, galleries, and funds. This repo is one of several open‑core components we maintain to showcase our engineering practices and to help prospective teammates explore our stack before interview day.

### Engineering principles

- **Clarity first** – readable code, rigorous tests, explanatory notebooks.
- **Automation over toil** – Makefile tasks, GitHub Actions CI, dbt for repeatable transformations.
- **Own the entire flow** – from raw CSV to interactive dashboards.

If you’re evaluating us as a potential employer, jump to [Contributing](#contributing) to see how we work day‑to‑day.

\$1

### 1  Clone & create an environment

```bash
$ git clone https://github.com/<your-handle>/famous-art-analytics.git
$ cd famous-art-analytics
$ python -m venv .venv
$ source .venv/bin/activate   # Windows: .venv\Scripts\activate
$ pip install -r requirements.txt
```

### 2  Set up the MySQL database

```bash
$ mysql -u <user> -p < sql/sql-database.sql
```

This creates a **famous\_paintings** database populated with tables such as `artist`, `work`, `subject`, `product_size`, `canvas_size` and more.

### 3  Run the analysis notebook

```bash
$ jupyter lab notebooks/famous_art_data_visualizations.ipynb
```

Execute the cells; feel free to tweak queries or chart styles and re‑run.

---

## Repository Layout

```
.
├── notebooks/
│   └── famous_art_data_visualizations.ipynb
├── sql/
│   └── sql-database.sql
├── data/            # raw CSV dump (git‑ignored)
├── reports/         # exported charts and tables
└── README.md
```

---

## Requirements

- **Python 3.10+**
- **MySQL 8.0+** (or MariaDB 10.5+)
- Python packages (see `requirements.txt`): `pandas`, `numpy`, `sqlalchemy`, `ipython-sql`, `matplotlib`, `seaborn`, `jupyterlab`

---

## Analysis Workflow

1. Load the SQL schema and sample data.
2. Execute the hypothesis queries directly in MySQL client or from the notebook.
3. Pull the results into `pandas` dataframes.
4. Build descriptive and inferential visualisations (bar charts, box plots, scatter plots).
5. Export high‑resolution figures to **/reports** for use in blogs or slide decks.

---

## Findings Preview

| Hypothesis  | Early signal                                                                                        |
| ----------- | --------------------------------------------------------------------------------------------------- |
| Style       | **Classicism** tops the average price list, followed by **American Landscape** and **Orientalism**. |
| Rarity      | Styles with <100 works often out‑earn the mainstream genres.                                        |
| Nationality | Within Impressionism, American painters’ median sale price is \~1.6× French contemporaries.         |
| Lifespan    | Works by artists who lived 65–74 years fetch the highest average price.                             |
| Subject     | Biblical scenes and seascapes outperform portraits.                                                 |

(*Full breakdown in the notebook; numbers will update as data grows.*)

---

## Roadmap

- **Make it easy to run locally** (Docker later if needed) — Owner: @chandlershortlidge
- **Organize the SQL into reusable chunks** — Owner: @chandlershortlidge
- **Add a basic dashboard with a few charts** — Owner: @chandlershortlidge

---

## Contributing

Pull requests are welcome! Please open an issue to discuss any substantial changes first. Make sure that:

- `pre-commit run --all-files` passes
- Your SQL complies with `sqlfluff`

---

## License

**MIT License**

---

## Acknowledgements

- Kaggle’s *Famous Paintings* dataset
- The r/DataIsBeautiful community for visualisation inspiration

