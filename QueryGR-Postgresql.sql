-- Database: goodreads

-- DROP DATABASE IF EXISTS goodreads;

CREATE DATABASE goodreads
    WITH
    OWNER = postgres
    ENCODING = 'UTF8'
    LC_COLLATE = 'English_United States.1252'
    LC_CTYPE = 'English_United States.1252'
    LOCALE_PROVIDER = 'libc'
    TABLESPACE = pg_default
    CONNECTION LIMIT = -1
    IS_TEMPLATE = False;

CREATE TABLE PUBLIC."book1-100k"( 
Id INT,
"Name" TEXT,
RatingDist1 VARCHAR(100),
pagesNumber INT,
RatingDist4 VARCHAR(100),
RatingDistTotal VARCHAR(100),
PublishMonth INT,
PublishDay INT,
Publisher VARCHAR(150),
CountsOfReview INT,
PublishYear INT,
"Language" VARCHAR(150),
Authors TEXT,
Rating FLOAT,
RatingDist2 VARCHAR(100),
RatingDist5 VARCHAR(100),
ISBN VARCHAR(100),
RatingDist3 VARCHAR(100)
);

COPY PUBLIC."book1-100k" FROM 'C:\Users\letic\OneDrive\Escritorio\book1-100k.csv' DELIMITER ',' CSV HEADER;


CREATE TABLE Books(
id SERIAL PRIMARY KEY,
"Name" TEXT,
pagesNumber INT,
publishMonth INT,
publishDay INT,
publishYear INT,
publisher VARCHAR(150),
ISBN VARCHAR(100),
"Language" VARCHAR(150),
Rating FLOAT,
countsOfReview INT,
AuthorId INT,
idUserCrea INT,
idUserMod INT DEFAULT NULL,
fechaCrea DATE,
fechaMod DATE DEFAULT NULL
);

CREATE TABLE Author(
id SERIAL PRIMARY KEY,
"Name" TEXT,
AuthorId INT,
idUserCrea INT,
idUserMod INT DEFAULT NULL,
fechaCrea DATE,
fechaMod DATE DEFAULT NULL
);

CREATE TABLE Ratings(
id SERIAL PRIMARY KEY,
RatingD1 VARCHAR(100),
RatingD2 VARCHAR(100),
RatingD3 VARCHAR(100),
RatingD4 VARCHAR(100),
RatingD5 VARCHAR(100),
RatingDTotal VARCHAR(100),
BookId INT,
idUserCrea INT,
idUserMod INT DEFAULT NULL,
fechaCrea DATE,
fechaMod DATE DEFAULT NULL
);

CREATE TABLE Users(
id SERIAL PRIMARY KEY,
nameU VARCHAR(50) NOT NULL,
username VARCHAR(50) NOT NULL,
passw VARCHAR(50),
estatus BOOLEAN DEFAULT TRUE
);

ALTER TABLE Books
ADD CONSTRAINT FK_BookAuthor
FOREIGN KEY(AuthorId) REFERENCES Author(id);

ALTER TABLE Ratings
ADD CONSTRAINT FK_BookRatings
FOREIGN KEY(BookId) REFERENCES Books(id);

ALTER TABLE Books
ADD CONSTRAINT FK_BookUserCrea
FOREIGN KEY (idUserCrea) REFERENCES Users(id);

ALTER TABLE Books
ADD CONSTRAINT FK_BookUserModifica
FOREIGN KEY (idUserMod) REFERENCES Users(id);

ALTER TABLE Author
ADD CONSTRAINT FK_AuthorUserCrea
FOREIGN KEY (idUserCrea) REFERENCES Users(id);

ALTER TABLE Author
ADD CONSTRAINT FK_AuthorUserModifica
FOREIGN KEY (idUserMod) REFERENCES Users(id);

ALTER TABLE Ratings
ADD CONSTRAINT FK_RatingUserCrea
FOREIGN KEY (idUserCrea) REFERENCES Users(id);

ALTER TABLE Ratings
ADD CONSTRAINT FK_RatingUserModifica
FOREIGN KEY (idUserMod) REFERENCES Users(id);

CREATE INDEX IX_Book ON Books(id);
CREATE INDEX IX_Author ON Author(id);
CREATE INDEX IX_Rating ON Ratings(id);
CREATE INDEX IX_User ON Users(id);

INSERT INTO Users (nameU, username, passw)
VALUES ('Perla', 'admin1', 'admin');
INSERT INTO Users (nameU, username, passw)
VALUES ('Kiara', 'admin','kiara');

SELECT * FROM Author;

INSERT INTO Author("Name",idUserCrea)
SELECT DISTINCT Authors, 1 FROM PUBLIC."book1-100k" WHERE Authors IS NOT NULL;

INSERT INTO Books ("Name", pagesNumber, publishMonth, publishDay, publishYear,
publisher, ISBN, "Language", Rating, countsOfReview, idUserCrea, fechaCrea)
SELECT "Name", pagesNumber, publishMonth, publishDay, publishYear,
publisher, ISBN, "Language", Rating, countsOfReview, 1, '2024-04-01'::DATE FROM PUBLIC."book1-100k";

UPDATE Books
SET AuthorId = Author.id
FROM PUBLIC."book1-100k"
INNER JOIN Author ON PUBLIC."book1-100k".Authors = Author."Name"
WHERE Books.id = PUBLIC."book1-100k".id;

UPDATE Author
SET AuthorId = Books.AuthorId
FROM Author A
INNER JOIN Books ON A."Name" = Books."Name";

-- Insertar datos en la tabla Ratings
INSERT INTO Ratings(RatingD1, RatingD2, RatingD3, RatingD4,
RatingD5, RatingDTotal, idUserCrea, fechaCrea)
SELECT RatingDist1, RatingDist2, RatingDist3, RatingDist4,
RatingDist5, RatingDistTotal, 1, '2024-04-01'::DATE FROM PUBLIC."book1-100k";

-- Actualizar el campo BookId en la tabla Ratings
UPDATE Ratings
SET BookId = Books.id
FROM PUBLIC."book1-100k"
INNER JOIN Books ON PUBLIC."book1-100k".id = Books.id
WHERE Ratings.id = PUBLIC."book1-100k".id;

-- CREATE BOOK
CREATE OR REPLACE FUNCTION SP_InsertBookWithRating(
    Name_param TEXT,
    pagesNumber_param INT,
    publishMonth_param INT,
    publishDay_param INT,
    publishYear_param INT,
    publisher_param VARCHAR(150),
    ISBN_param VARCHAR(100),
    Language_param VARCHAR(150),
    Rating_param FLOAT,
    countsOfReview_param INT,
    AuthorName_param VARCHAR(100),
    fechaCrea_param DATE,
    RatingD1_param VARCHAR(100),
    RatingD2_param VARCHAR(100),
    RatingD3_param VARCHAR(100),
    RatingD4_param VARCHAR(100),
    RatingD5_param VARCHAR(100),
    RatingDTotal_param VARCHAR(100)
) RETURNS VOID AS
$$
DECLARE
    BookId_param INT;
    AuthorId_param INT;
BEGIN
    SELECT INTO AuthorId_param id FROM Author WHERE "Name" = AuthorName_param;

    IF NOT FOUND THEN
        INSERT INTO Author ("Name") VALUES (AuthorName_param) RETURNING id INTO AuthorId_param;
    END IF;

    INSERT INTO Books ("Name", pagesNumber, publishMonth, publishDay, publishYear, publisher, ISBN, "Language", Rating, countsOfReview, AuthorId, fechaCrea)
    VALUES (Name_param, pagesNumber_param, publishMonth_param, publishDay_param, publishYear_param, publisher_param, ISBN_param, Language_param, Rating_param, countsOfReview_param, AuthorId_param, fechaCrea_param)
    RETURNING id INTO BookId_param;

    INSERT INTO Ratings (RatingD1, RatingD2, RatingD3, RatingD4, RatingD5, RatingDTotal, BookId)
    VALUES (RatingD1_param, RatingD2_param, RatingD3_param, RatingD4_param, RatingD5_param, RatingDTotal_param, BookId_param);
END;
$$ LANGUAGE plpgsql;



-----

SELECT * FROM Books order by id desc;
-- CREATE AUTHOR
CREATE OR REPLACE FUNCTION SP_InsertAuthor(
    Name_param TEXT,
    idUserCrea_param INT,
    fechaCrea_param DATE
) RETURNS VOID AS
$$
BEGIN
    INSERT INTO Author ("Name", idUserCrea, fechaCrea)
    VALUES (Name_param, idUserCrea_param, fechaCrea_param);
END;
$$ LANGUAGE plpgsql;

-- CREATE USER
CREATE OR REPLACE FUNCTION SP_InsertUser(
    Name_param VARCHAR(50),
    Username_param VARCHAR(50),
    Password_param VARCHAR(50)
) RETURNS VOID AS
$$
BEGIN
    INSERT INTO Users (nameU, username, passw)
    VALUES (Name_param, Username_param, ENCODE(DIGEST(Password_param, 'sha1'), 'hex'));
END;
$$ LANGUAGE plpgsql;

-- READ BOOK
CREATE OR REPLACE FUNCTION SP_ReadBooks() RETURNS TABLE (
    id INT,
    "Name" TEXT,
    pagesNumber INT,
    publishMonth INT,
    publishDay INT,
    publishYear INT,
    publisher VARCHAR(150),
    ISBN VARCHAR(100),
    "Language" VARCHAR(150),
    Rating FLOAT,
    countsOfReview INT,
    AuthorId INT
) AS
$$
BEGIN
    RETURN QUERY SELECT id, "Name", pagesNumber, publishMonth, publishDay, publishYear, publisher, ISBN, "Language", Rating, countsOfReview, AuthorId FROM Books;
END;
$$ LANGUAGE plpgsql;

-- READ AUTHOR
CREATE OR REPLACE FUNCTION SP_ReadAuthors() RETURNS TABLE (
    id INT,
    "Name" TEXT
) AS
$$
BEGIN
    RETURN QUERY SELECT id, "Name" FROM Author;
END;
$$ LANGUAGE plpgsql;

--UPDATE BOOKS AND RATING
CREATE OR REPLACE FUNCTION SP_UpdateBookAndRating(
    BookId_param INT,
    Name_param VARCHAR,
    pagesNumber_param INT,
    publishMonth_param INT,
    publishDay_param INT,
    publishYear_param INT,
    publisher_param VARCHAR(150),
    ISBN_param VARCHAR(100),
    Language_param VARCHAR(150),
    Rating_param FLOAT,
    countsOfReview_param INT,
    AuthorName_param VARCHAR(100),
    idUserMod_param INT,
    fechaMod_param DATE,
    RatingD1_param VARCHAR(100),
    RatingD2_param VARCHAR(100),
    RatingD3_param VARCHAR(100),
    RatingD4_param VARCHAR(100),
    RatingD5_param VARCHAR(100),
    RatingDTotal_param VARCHAR(100)
) RETURNS VOID AS
$$
DECLARE
    AuthorId_param INT;
BEGIN
    SELECT INTO AuthorId_param id FROM Author WHERE "Name" = AuthorName_param;

    IF NOT FOUND THEN
        INSERT INTO Author ("Name") VALUES (AuthorName_param) RETURNING id INTO AuthorId_param;
    END IF;

    UPDATE Books
    SET "Name" = Name_param,
        pagesNumber = pagesNumber_param,
        publishMonth = publishMonth_param,
        publishDay = publishDay_param,
        publishYear = publishYear_param,
        publisher = publisher_param,
        ISBN = ISBN_param,
        "Language" = Language_param,
        Rating = Rating_param,
        countsOfReview = countsOfReview_param,
        AuthorId = AuthorId_param,
        idUserMod = idUserMod_param,
        fechaMod = fechaMod_param
    WHERE id = BookId_param;

    UPDATE Ratings
    SET RatingD1 = RatingD1_param,
        RatingD2 = RatingD2_param,
        RatingD3 = RatingD3_param,
        RatingD4 = RatingD4_param,
        RatingD5 = RatingD5_param,
        RatingDTotal = RatingDTotal_param,
        idUserMod = idUserMod_param,
        fechaMod = fechaMod_param
    WHERE BookId = BookId_param;
END;
$$ LANGUAGE plpgsql;

-- UPDATE AUTHOR
CREATE OR REPLACE FUNCTION SP_UpdateAuthor(
    AuthorId_param INT,
    Name_param VARCHAR,
    idUserMod_param INT,
    fechaMod_param DATE
) RETURNS VOID AS
$$
BEGIN
    UPDATE Author
    SET "Name" = Name_param,
        idUserMod = idUserMod_param,
        fechaMod = fechaMod_param
    WHERE id = AuthorId_param;
END;
$$ LANGUAGE plpgsql;

-- UPDATE USER
CREATE OR REPLACE FUNCTION SP_UpdateUser(
    UserId_param INT,
    Name_param VARCHAR(50),
    Username_param VARCHAR(50),
    Password_param VARCHAR(50),
    Estatus_param BOOLEAN
) RETURNS VOID AS
$$
BEGIN
    UPDATE Users
    SET nameU = Name_param,
        username = Username_param,
        passw= Password_param,
        estatus = Estatus_param
    WHERE id = UserId_param;
END;
$$ LANGUAGE plpgsql;

-- DELETE BOOK
CREATE OR REPLACE FUNCTION SP_DeleteBookAndRatings(
    p_BookId INT
)
RETURNS VOID
AS $$
BEGIN
    BEGIN
        DELETE FROM Ratings WHERE BookId = p_BookId;
        DELETE FROM Books WHERE id = p_BookId;
    EXCEPTION
        WHEN OTHERS THEN
            RAISE EXCEPTION '%', SQLERRM;
    END;
END;
$$
LANGUAGE plpgsql;


-- DELETE AUTHOR
CREATE OR REPLACE FUNCTION SP_DeleteAuthor(
    AuthorId_param INT
)
RETURNS VOID
AS $$
BEGIN
    DELETE FROM Books WHERE AuthorId = AuthorId_param;
    DELETE FROM Author WHERE id = AuthorId_param;
EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION '%', SQLERRM;
END;
$$
LANGUAGE plpgsql;

-- DELETE USER
CREATE OR REPLACE FUNCTION SP_DeleteUser(
    UserId_param INT
) RETURNS VOID AS
$$
BEGIN
    DELETE FROM Users
    WHERE id = UserId_param;
END;
$$ LANGUAGE plpgsql;

--TRIGGER DELETE USER
CREATE OR REPLACE FUNCTION trg_prevent_delete_user() RETURNS TRIGGER AS
$$
BEGIN
    UPDATE Users
    SET estatus = FALSE 
    WHERE id IN (SELECT id FROM old);
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER TRG_PreventDeleteUser
BEFORE DELETE ON Users
FOR EACH ROW
EXECUTE FUNCTION trg_prevent_delete_user();

-- VIEW VW_FichaBibliografica
CREATE VIEW VW_FichaBibliografica AS
SELECT Books.id, Books."Name" AS "Título", Books.publishYear AS "Año de publicación",
Books.publisher AS "Editorial", Author."Name" AS "Autor" FROM Books
INNER JOIN Author ON Author.id = Books.AuthorId;

-- VIEW VW_BooksAndRatings
CREATE VIEW VW_BooksAndRatings AS
SELECT Books.id, Books."Name" AS "Título", Books.pagesNumber AS "No. páginas",
Books.publishMonth AS "Mes de publicación", Books.publishDay AS "Día de publicación",
Books.publishYear AS "Año de publicación", Books.publisher AS "Editorial", Books.ISBN,
Books."Language" AS "Idioma", Books.Rating, Books.countsOfReview AS "No. Total de reseñas",
Author."Name" AS "Autor", Ratings.RatingD1 AS "Rating 1", Ratings.RatingD2 AS "Rating 2",
Ratings.RatingD3 AS "Rating 3", Ratings.RatingD4 AS "Rating 4", Ratings.RatingD5 AS "Rating 5",
Ratings.RatingDTotal AS "Total Rating" FROM Books
INNER JOIN Author ON Author.id = Books.AuthorId
INNER JOIN Ratings ON Ratings.BookId = Books.id;

SELECT * FROM VW_BooksAndRatings;
SELECT * FROM Books WHERE id=12082;
SELECT * FROM Author ORDER BY id DESC;