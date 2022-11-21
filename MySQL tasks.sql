--СВЯЗИ МЕЖДУ ТАБЛИЦАМИ

/* 1. Создать таблицу author следующей структуры:

Поле	Тип, описание
author_id	     INT PRIMARY KEY AUTO_INCREMENT
name_author	VARCHAR(50) */

create table author(
author_id	INT PRIMARY KEY AUTO_INCREMENT,
name_author VARCHAR(50));

/*2. Заполнить таблицу author. В нее включить следующих авторов:

Булгаков М.А.
Достоевский Ф.М.
Есенин С.А.
Пастернак Б.Л.*/

INSERT INTO author (name_author)
VALUES
    ('Булгаков М.А.'),
    ('Достоевский Ф.М.'),
    ('Есенин С.А.'),
    ('Пастернак Б.Л.');

/* 3. Перепишите запрос на создание таблицы book , чтобы ее структура соответствовала структуре, показанной на логической схеме (таблица genre уже создана, порядок следования столбцов - как на логической схеме в таблице book, genre_id  - внешний ключ) . Для genre_id ограничение о недопустимости пустых значений не задавать. В качестве главной таблицы для описания поля  genre_idиспользовать таблицу genre следующей структуры:

Поле	Тип, описание
genre_id	INT PRIMARY KEY AUTO_INCREMENT
name_genre	VARCHAR(30)*/

CREATE TABLE book (
    book_id INT PRIMARY KEY AUTO_INCREMENT, 
    title VARCHAR(50), 
    author_id INT NOT NULL, 
    genre_id INT,
    price DECIMAL(8,2), 
    amount INT, 
    FOREIGN KEY (author_id)  REFERENCES author (author_id),
    FOREIGN KEY (genre_id)  REFERENCES genre (genre_id)
);

/* 4. Создать таблицу book той же структуры, что и на предыдущем шаге. Будем считать, что при удалении автора из таблицы author, должны удаляться все записи о книгах из таблицы book, написанные этим автором. А при удалении жанра из таблицы genre для соответствующей записи book установить значение Null в столбце genre_id. */

CREATE TABLE book (
    book_id INT PRIMARY KEY AUTO_INCREMENT, 
    title VARCHAR(50), 
    author_id INT NOT NULL, 
    genre_id INT,
    price DECIMAL(8,2), 
    amount INT, 
    FOREIGN KEY (author_id)  REFERENCES author (author_id) ON DELETE CASCADE,
    FOREIGN KEY (genre_id)  REFERENCES genre (genre_id) ON DELETE SET NULL
);

--ЗАПРОСЫ НА ВЫБОРКУ, СОЕДИНЕНИЕ ТАБЛИЦ

/* 1. Вывести название, жанр и цену тех книг, количество которых больше 8, в отсортированном по убыванию цены виде.*/

SELECT title, name_genre, price
FROM genre as g INNER JOIN book as b
ON g.genre_id = b.genre_id
where b.amount > 8
order by price desc;

/* 2. Вывести все жанры, которые не представлены в книгах на складе.*/

select name_genre 
from genre as g left join book as b
on g.genre_id = b.genre_id
where title is null;

/* 3. Необходимо в каждом городе провести выставку книг каждого автора в течение 2020 года. Дату проведения выставки выбрать случайным образом. Создать запрос, который выведет город, автора и дату проведения выставки. Последний столбец назвать Дата. Информацию вывести, отсортировав сначала в алфавитном порядке по названиям городов, а потом по убыванию дат проведения выставок.*/

select name_city, name_author, DATE_ADD('2020-01-01',INTERVAL FLOOR(RAND() * 365) DAY) AS  Дата
from city, author
order by name_city,  Дата desc;

/* 4.  Вывести информацию о книгах (жанр, книга, автор), относящихся к жанру, включающему слово «роман» в отсортированном по названиям книг виде*/

SELECT name_genre, title, name_author
FROM author 
    INNER JOIN  book ON author.author_id = book.author_id
    INNER JOIN genre ON genre.genre_id = book.genre_id and name_genre = 'Роман'
WHERE name_genre = 'Роман'
ORDER BY title;

/* 5. Посчитать количество экземпляров  книг каждого автора из таблицы author.  Вывести тех авторов,  количество книг которых меньше 10, в отсортированном по возрастанию количества виде. Последний столбец назвать Количество*/

select name_author, sum(amount) as Количество
from 
    author as a left join book as b
    on a.author_id = b.author_id
group by name_author
having sum(amount)<10 or sum(amount) is null
order by sum(amount);

/* 6. Вывести в алфавитном порядке всех авторов, которые пишут только в одном жанре. Поскольку у нас в таблицах так занесены данные, что у каждого автора книги только в одном жанре,  для этого запроса внесем изменения в таблицу book. Пусть у нас  книга Есенина «Черный человек» относится к жанру «Роман», а книга Булгакова «Белая гвардия» к «Приключениям» (эти изменения в таблицы уже внесены).*/

SELECT name_author 
FROM author
  LEFT JOIN book
  ON author.author_id = book.author_id
GROUP BY author.author_id
HAVING MIN(genre_id) = MAX(genre_id)
ORDER BY name_author;

/* 7. Вывести информацию о книгах (название книги, фамилию и инициалы автора, название жанра, цену и количество экземпляров книги), написанных в самых популярных жанрах, в отсортированном в алфавитном порядке по названию книг виде. Самым популярным считать жанр, общее количество экземпляров книг которого на складе максимально.*/

select title, name_author, name_genre, price*1.5, amount
from author 
        inner join book on author.author_id = book.author_id
        inner join genre on genre.genre_id = book.genre_id
where book.title not like '_% _%' and book.genre_id in( 
                  SELECT genre_id
                  FROM book
                  GROUP BY genre_id
                  HAVING avg(amount) <= ALL(SELECT SUM(amount) as ss
                                            from book 
                                            group by genre_id))
order by title, name_author, amount desc

















