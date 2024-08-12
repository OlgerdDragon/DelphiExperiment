CREATE TABLE Products (
    id INT PRIMARY KEY IDENTITY,
    name NVARCHAR(255),
    price DECIMAL(18, 2),
    category_id INT
);

CREATE TABLE Sales (
    id INT PRIMARY KEY IDENTITY,
    date DATETIME,
    customer_name NVARCHAR(255)
);

CREATE TABLE SalesDetails (
    sale_id INT,
    product_id INT,
    qty INT,
    price DECIMAL(18, 2),
    PRIMARY KEY (sale_id, product_id),
    FOREIGN KEY (sale_id) REFERENCES Sales(id),
    FOREIGN KEY (product_id) REFERENCES Products(id)
);

CREATE TABLE ProductCategories (
    id INT PRIMARY KEY IDENTITY,
    name NVARCHAR(255),
    parent_category_id INT,
    FOREIGN KEY (parent_category_id) REFERENCES ProductCategories(id)
);
