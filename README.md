# Target-Analysis---BQ  

## PROJECT OVERVIEW:  

## TOOLS USED:
**EXCEL** : Datset  
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
<img width="1196" height="712" alt="Target BQ ER trial" src="https://github.com/user-attachments/assets/9999c2fb-a5d6-4148-b264-cdcf083e9c30" />



## INSIGHTS & RECOMMENDATION:  



## LINK TO THE TARGET ANALYSIS LOOKER DASHBOARD : https://lookerstudio.google.com/reporting/a675c0b9-d735-4fc8-a532-6aa30b1c3ac5  
