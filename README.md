# Target-Analysis---BQ  

## PROJECT OVERVIEW:  
Analysed and visualised an ecommerce dataset to gain insight on the orders, common order times, average price, freight value, etc.   


## TOOLS USED:
**EXCEL** : Dataset  
**BigQuery**: For SQL analysis  
**Looker Studio** : For visualisation.  

## DATASET OVERVIEW:  There are 8 Tables in this dataset.    

1. 🛒 **orders:  PK-> order_id**   
Contains an overview of orders. Includes order purchase time, order status,estimated deliver date, delivery date.  
   
2. 📦 **order_items: PK-> order_id**
Stores item level details for each order, such as product ID, shipping deadline, item price, freight value, and seller ID.  

3. 👤**Customers: PK-> customer_id**    
Contains customer data like customer_id, state, city, zip code.  

4. 💳 **Payments:  PK-> order_id**
Contains payment details, including total payment amount, payment type, number of installments, and payment sequence number.
   
5. ⭐**Order_review:  PK-> review_id**   
Stores customer review information such as review score, review title, review creation timestamp, and review response time.

6. 🏪**Sellers: PK-> seller_id**    
Seller details like Seller id, seller state, city and zip code.  

7. 🗺️**Geolocation: PK-> geolocation_zip_code**  
Includes geographical information linked to ZIP codes, such as state, city, latitude, and longitude.

8. 🏷️**Products: PK-> product_id**    
Product level details like product id, product category, and physical attributes like product height,weight,length,width,photos etc.  



## ER DIAGRAM :  
<img width="1080" height="631" alt="Target Analysis ER Diagram" src="https://github.com/user-attachments/assets/a819d73f-88e5-429d-925d-97d860eea721" />


## DASHBOARD:
<img width="1300" height="731" alt="Weather Dashboard" src="https://github.com/user-attachments/assets/f081b8eb-8e77-4be1-aeb2-89ac0e3f1c71" />


## INSIGHTS & RECOMMENDATION:  



## LINK TO THE TARGET ANALYSIS LOOKER DASHBOARD : https://lookerstudio.google.com/reporting/a675c0b9-d735-4fc8-a532-6aa30b1c3ac5  
