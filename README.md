# Target-Analysis---BQ  

## PROJECT OVERVIEW:  

## DATASET OVERVIEW:  There are 8 Tables in this dataset.    

1. 🛒 **orders:  PK-> order_id**   
Contains an overview of orders. Includes order purchase time, order status,estimated deliver date, delivery date.  
   
2. 📦 **order_items: PK-> order_id**    
Contains details of the products ordered, the shipping limit date, the price , freight value and the seller.  

3. 👤**Customers: PK-> customer_id**    
Contains customer data like customer_id, state, city, zip code.  

4. 💳 **Payments:  PK-> order_id**   
Payment details like total payment value, type of payment, installments and the payment sequential number.  
   
6. ⭐**Order_review:  PK-> review_id**   
Review details like the review score, review title ,its creation time and review response time.    

7. 🏪**Sellers: PK-> seller_id**    
Seller details like Seller id, seller state, city and zip code.  

8. 🗺️**Geolocation: PK-> geolocation_zip_code**  
Contaains the geolocation data for the dataset which includes geolocation zip code, state,city, lat, long.   

9. 🏷️**Products: PK-> product_id**    
Product details like product id, product category, product height,weight,length,width,photos etc.  
   

orders: 🛒 PK → order_id
Contains an overview of orders. Includes order purchase time, order status, estimated deliver date, delivery date.

order_items: 📦 PK → order_id
Contains details of the products ordered, the shipping limit date, the price, freight value and the seller.

customers: 👤 PK → customer_id
Contains customer data like customer_id, state, city, zip code.

payments: 💳 PK → order_id
Payment details like total payment value, type of payment, installments and the payment sequential number.

order_review: ⭐ PK → review_id
Review details like the review score, review title, its creation time and review response time.

sellers: 🏪 PK → seller_id
Seller details like seller id, seller state, city and zip code.

geolocation: 🗺️ PK → geolocation_zip_code
Contains the geolocation data for the dataset which includes geolocation zip code, state, city, latitude, longitude.

products: 🏷️ PK → product_id
Product details like product id, product category, product height, weight, length, width, photos etc.

## ER DIAGRAM :  


## INSIGHTS & RECOMMENDATION:  



## LINK TO THE TARGET ANALYSIS LOOKER DASHBOARD : https://lookerstudio.google.com/reporting/a675c0b9-d735-4fc8-a532-6aa30b1c3ac5  
