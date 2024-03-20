-- No 1:
-- Buatlah query untuk menampilkan nama pelanggan yang pernah melakukan
-- pembayaran pada tahun 2003 dengan amount >50000 atau <10000. Tampilkan dengan
-- amount terurut membesar.
SELECT customerNumber 
FROM customers NATURAL JOIN payments 
WHERE YEAR(paymentDate) = 2003 AND (amount > 50000 OR amount < 10000);

-- No 2:
-- Buatlah sebuah view yang bernama “cancelled_order” untuk pesanan dengan status
-- “Cancelled”. Dalam view tersebut, data yang disertakan adalah nama lengkap contact
-- sebagai “contact_name”, nomor telepon, tanggal pemesanan, nama produk yang
-- dipesan, status, dan komentar. Urutkan dari tanggal yang terbaru.
CREATE VIEW cancelled_order AS
SELECT 
    CONCAT(contactFirstName, " ", contactLastName) AS contact_name, 
    phone, 
    orderDate, 
    productName,    
    status, 
    comments 
FROM customers 
    NATURAL JOIN orders
    NATURAL JOIN orderDetails
    NATURAL JOIN products
WHERE status = "Cancelled"
ORDER BY orderDate DESC;

-- No 3:
-- Buatlah query untuk mengubah posisi pekerjaan menjadi 'Sales Manager' dari pegawai
-- dengan total payment yang dilakukan oleh semua pelanggan dari negara USA yang
-- dilayaninya lebih dari 500000.
-- Buktikan dengan screenshot sebelum dan sesudah dilakukan perubahan. Pastikan
-- screenshot memperlihatkan juga bagian jumlah rows.
SELECT * 
FROM employees 
WHERE employeeNumber =
    (SELECT employeeNumber
    FROM employees 
        INNER JOIN customers ON (salesRepEmployeeNumber = employeeNumber)
        NATURAL JOIN payments
    WHERE country = "USA"
    GROUP BY employeeNumber
    HAVING SUM(amount) > 500000);  

UPDATE employees 
SET jobTitle = "Sales Manager"
WHERE employeeNumber =
    (SELECT employeeNumber
    FROM employees 
        INNER JOIN customers ON (salesRepEmployeeNumber = employeeNumber)
        NATURAL JOIN payments
    WHERE country = "USA"
    GROUP BY employeeNumber
    HAVING SUM(amount) > 500000);  

-- No 4:
-- Perusahaan memutuskan untuk membuat kantor cabang baru. Buatlah entri baru di
-- dalam tabel offices dengan data sebagai berikut!
-- officeCode : 8
-- city : Bandung
-- phone : +62 831 8243 4940
-- addressLine1 : Jl. Ganesha No. 10
-- addressLine2 : Labtek V
-- state : NULL
-- country : Indonesia
-- postalCode : 40132
-- territory : APAC
-- Buktikan dengan screenshot sebelum dan sesudah dilakukan perubahan
SELECT addressLine1 FROM offices WHERE officeCode = 7;

INSERT INTO offices
    VALUES (8, 'Bandung', '+62 831 8243 4940', 'Jl. Ganesha No. 10', 'Labtek V',
             NULL, 'Indonesia', '40132', 'APAC')

-- No 5:
-- Beberapa nomor telepon customer tidak terhubung ke whatsapp sehingga pengeluaran
-- perusahaan membengkak hanya untuk membeli pulsa. Perusahaan memutuskan untuk
-- menambahkan kolom baru bernama ‘email’ ke tabel customers. Kolom ini memiliki tipe
-- data varchar(255) dan nilai default NULL. Kemudian, ubah semua nilai kolom email
-- dengan format sebagai berikut.
-- “<contactFirstName><contactLastName>@gmail.com”
-- Buktikan dengan screenshot eksekusi query penambahan kolom ‘email’ dan isi dari
-- kolom tersebut setelah dilakukan perubahan!
-- Catatan: Pastikan alamat email tidak mengandung spasi dan semuanya huruf kecil.
-- Gunakan fungsi REPLACE(), LOWER(), dan CONCAT()

ALTER TABLE customers 
ADD email varchar(255) DEFAULT NULL;

SELECT email FROM customers; 

UPDATE customers 
SET email = REPLACE(CONCAT(LOWER(contactFirstName), LOWER(contactLastName), '@gmail.com'), ' ', ''); 

-- no 6:
-- Perusahaan memutuskan untuk memecat pegawai dari kantor cabang di kota London
-- yang belum pernah melayani customer dari kota Liverpool
-- Clue:
--  ● Gunakan temporary table mariadb documentation
--  ● sebelum menghapus data pegawai, set NULL untuk kolom foreign key pada tabel
--    customers yang pernah dilayani pegawai tersebut
-- Buktikan dengan screenshot eksekusi query yang memuat nama customer (dari kota
-- Liverpool) dan nomor pegawai yang melayaninya (dari kantor cabang kota London)
-- sebelum dan sesudah dilakukan perubahan

CREATE TEMPORARY TABLE employeefired AS ( 
    (SELECT employeeNumber 
    FROM employees NATURAL JOIN offices
    WHERE city = 'London')
    EXCEPT
    (SELECT employeeNumber
    FROM customers AS c
        JOIN employees ON (salesRepEmployeeNumber = employeeNumber),
        offices AS f 
    WHERE c.city = 'Liverpool' AND f.city = 'London')
);

SELECT customerName, salesRepEmployeeNumber
FROM customers AS c
    JOIN employees ON (salesRepEmployeeNumber = employeeNumber),
    offices AS f 
WHERE c.city = 'Liverpool' AND f.city = 'London';

UPDATE customers
SET salesRepEmployeeNumber = NULL
WHERE salesRepEmployeeNumber IN (SELECT employeeNumber FROM employeefired);

DELETE FROM employees WHERE employeeNumber IN (SELECT employeeNumber FROM employeefired);

-- No 7:
-- Perusahaan berencana untuk menambahkan daftar pabrik yang memproduksi
-- produk-produk yang ada dalam tabel produk. Setiap pabrik bisa memproduksi lebih dari
-- satu produk. Selain itu, karena demand produk yang cukup tinggi, setiap produk juga
-- bisa diproduksi oleh beberapa pabrik. Oleh karena itu, dibutuhkan dua tabel baru. Tabel
-- pertama adalah tabel bernama warehouse yang mencatat daftar pabrik yang ada.
-- Berikut adalah deskripsi tabel warehouse yang harus dibuat:
    -- ● warehouseCode : primary key dengan tipe data integer
    -- ● warehouseName : maksimal 50 karakter dan setiap pabrik harus mempunyai
    -- nama
    -- ● managerName: maksimal 255 karakter dan setiap pabrik harus mempunyai
    -- manager
    -- ● addressLine : maksimal 255 karakter dan setiap pabrik harus mempunyai
    -- informasi ini
    -- ● city: setiap pabrik harus mempunyai informasi ini
    -- ● country: setiap pabrik harus mempunyai informasi ini
    -- Tabel kedua adalah tabel manufacture yang hanya mempunyai 2 kolom dengan
    -- deskripsi sebagai berikut:
    -- ● productCode: foreign key yang menunjuk ke kolom productCode pada tabel
    -- product dan tidak boleh NULL, tipe data adalah VARCHAR dengan maksimal
    -- karakter sebanyak 15 karakter
    -- ● warehouseCode: foreign key yang menunjuk ke kolom warehouseCode pada
    -- tabel warehouse dan tidak boleh NULL
-- Primary key pada tabel kedua merupakan primary key komposit, yaitu kolom
-- productCode dan warehouseCode. Tampilkan juga screenshot hasil perintah DESCRIBE
-- untuk tabel pertama dan kedua setelah berhasil dibuat.
-- PENTING: Set collation menjadi latin1_swedish_ci saat membuat tabel manufacture
-- pada akhir syntax CREATE TABLE, seperti berikut ini:
    -- CREATE TABLE manufacture (
    -- ....
    -- ) COLLATE=latin1_swedish_ci;
CREATE TABLE warehouse (
    warehouseCode INT AUTO_INCREMENT,
    warehouseName VARCHAR(50) NOT NULL,
    managerName VARCHAR(255) NOT NULL,
    addressLine VARCHAR(255) NOT NULL,
    city VARCHAR(255) NOT NULL,
    country VARCHAR(255) NOT NULL,
    PRIMARY KEY(warehouseCode)
);

CREATE TABLE manufacture (
    productCode VARCHAR(15) NOT NULL,
    warehouseCode INT NOT NULL,
    CONSTRAINT `fk_product_code`
        FOREIGN KEY (productCode)
        REFERENCES products(productCode),
    CONSTRAINT `fk_warehouse_code`
        FOREIGN KEY (warehouseCode)
        REFERENCES warehouse(warehouseCode),
    PRIMARY KEY (productCode, warehouseCode)
)
COLLATE = latin1_swedish_ci;