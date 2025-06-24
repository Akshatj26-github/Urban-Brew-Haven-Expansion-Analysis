# Urban Brew Haven Expansion Analysis ☕️

## *Crafting Experiences, One Brew at a Time*
![image](https://github.com/user-attachments/assets/31844c54-32bc-4f6e-b9a1-bd6e73105416)

## Objective

The goal of this project is to analyze the sales data of Urban Brew Haven, a company that has been selling its products online since January 2023, and to recommend the top three major cities in India for opening new coffee shop locations based on consumer demand, sales performance, and rent efficiency.

## Dataset Files
1. `city.csv` - City demographics and rent data
2. `customers.csv` - Customer information
3. `products.csv` - Coffee product details
4. `sales.csv` - Transaction records

## ER Diagram

```mermaid

erDiagram

city ||--o{ customers : "has"

city {

INT city_id PK

VARCHAR(15) city_name

BIGINT population

FLOAT estimated_rent

INT city_rank

}

customers ||--o{ sales : "places"

customers {

INT customer_id PK

VARCHAR(25) customer_name

INT city_id FK

}

products ||--o{ sales : "ordered_in"

products {

INT product_id PK

VARCHAR(35) product_name

FLOAT Price

}

sales {

INT sale_id PK

DATE sale_date

INT product_id FK

INT customer_id FK

FLOAT total

INT rating

}

```

