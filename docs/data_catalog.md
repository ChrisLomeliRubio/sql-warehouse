This file will help the user to understand the contents of the gold layer, also gives a brief description of other layers telling
how they work, but doesn't go deep in detail as much as with the gold layer


- Bronze layer
    This layer is the first of all three, it helps creating the base of the other layers, it cointains
    data as-is from the files, it is dirty and unfiltered
- Silver layer
    This layers takes the data from the bronze layer and proceeds to filter and clean data, handling the nulls
    and all the bad data that we could find
- Gold layer
    This layer is the most friendly of the three. It contains ready to use data for analitycs and bussines partners.
    the data is filtered and can easily be used to perform aggregations.

  *Gold layer tables*

  gold.fact_sales
  -order_number/NVARCHAR(50)/ Stores a unique alpha-numeric number to represent the transaction
  -product_key/INT/ Creates a unique ID of the product, helping with joining data (surrogate key)
  -customer_key/INT/ Creates a unique ID of the costumers, helpful joining data (surrogate key)
  -order_date/DATE/ Stores the date when the order was placed
  -ship_date/DATE/ Stores the date of when the order was shipped
  -due_date/DATE/ Stores the due date of the order
  -sales/INT/ Stores the total monetary value of a sale
  -quantity/INT/ Stores the quantity of the sold product in a transaction
  -cost/INT/ Stores the price of the product when it was sold (whole units)

  gold.dim_customers
