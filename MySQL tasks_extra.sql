--ЗАПРОСЫ НА ВЫБОРКУ

/* 1. Вывести студентов, которые сдавали дисциплину «Основы баз данных», указать дату попытки и результат. Информацию вывести по убыванию результатов тестирования.*/

select name_student, date_attempt, result
from subject join attempt using (subject_id)
join student using (student_id)
where name_subject = 'Основы баз данных'
order by result desc;

/* 2. Вывести, сколько попыток сделали студенты по каждой дисциплине, а также средний результат попыток, который округлить до 2 знаков после запятой. Под результатом попытки понимается процент правильных ответов на вопросы теста, который занесен в столбец result.  В результат включить название дисциплины, а также вычисляемые столбцы Количество и Среднее. Информацию вывести по убыванию средних результатов.*/

select name_subject, count(result) as Количество, round(avg(result),2) as Среднее
from subject left join attempt  using (subject_id)
group by  subject_id
order by name_subject;

/* 3. Вывести студентов (различных студентов), имеющих максимальные результаты попыток . Информацию отсортировать в алфавитном порядке по фамилии студента.*/

select name_student, result
from student join attempt using (student_id)
where result = (select max(result) from attempt)
order by result desc;

/* 4. Если студент совершал несколько попыток по одной и той же дисциплине, то вывести разницу в днях между первой и последней попыткой. В результат включить фамилию и имя студента, название дисциплины и вычисляемый столбец Интервал. Информацию вывести по возрастанию разницы. Студентов, сделавших одну попытку по дисциплине, не учитывать. */

select name_student, name_subject, DATEDIFF(max(date_attempt), min(date_attempt)) as Интервал
from subject join attempt using (subject_id)
             join student using (student_id)
group by student_id, subject_id
having count(subject_id)>=2
order by Интервал

/* 5. Студенты могут тестироваться по одной или нескольким дисциплинам (не обязательно по всем). Вывести дисциплину и количество уникальных студентов (столбец назвать Количество), которые по ней проходили тестирование . Информацию отсортировать сначала по убыванию количества, а потом по названию дисциплины. В результат включить и дисциплины, тестирование по которым студенты не проходили, в этом случае указать количество студентов 0.*/

select name_subject, count(student_id) as Количество
from (select name_subject, student_id
      from subject left join attempt using (subject_id)
      group by student_id,name_subject) as new
group by name_subject
order by Количество desc,name_subject;

/* 6. Случайным образом отберите 3 вопроса по дисциплине «Основы баз данных». В результат включите столбцы question_id и name_question.*/

select question_id, name_question
from subject join question using (subject_id)
where name_subject = 'Основы баз данных'
ORDER BY RAND()
limit 3

/* 7. Вывести вопросы, которые были включены в тест для Семенова Ивана по дисциплине «Основы SQL» 2020-05-17  (значение attempt_id для этой попытки равно 7). Указать, какой ответ дал студент и правильный он или нет (вывести Верно или Неверно). В результат включить вопрос, ответ и вычисляемый столбец  Результат.*/

select name_question, name_answer, if(is_correct=1,'Верно','Неверно') as Результат
from question join testing using (question_id)
              join answer using (answer_id)
where subject_id = 1 and attempt_id=7;

/* 8. Посчитать результаты тестирования. Результат попытки вычислить как количество правильных ответов, деленное на 3 (количество вопросов в каждой попытке) и умноженное на 100. Результат округлить до двух знаков после запятой. Вывести фамилию студента, название предмета, дату и результат. Последний столбец назвать Результат. Информацию отсортировать сначала по фамилии студента, потом по убыванию даты попытки.*/

select name_student, name_subject, date_attempt, round((sum(is_correct)/3*100),2) as Результат
from attempt join student using (student_id)
            join subject using (subject_id)
            join testing using(attempt_id)
            join answer using(answer_id)
group by name_student, name_subject, date_attempt
order by name_student, date_attempt desc;

/* 9. Для каждого вопроса вывести процент успешных решений, то есть отношение количества верных ответов к общему количеству ответов, значение округлить до 2-х знаков после запятой. Также вывести название предмета, к которому относится вопрос, и общее количество ответов на этот вопрос. В результат включить название дисциплины, вопросы по ней (столбец назвать Вопрос), а также два вычисляемых столбца Всего_ответов и Успешность. Информацию отсортировать сначала по названию дисциплины, потом по убыванию успешности, а потом по тексту вопроса в алфавитном порядке.
Поскольку тексты вопросов могут быть длинными, обрезать их 30 символов и добавить многоточие "...".*/

SELECT name_subject,
       CONCAT(LEFT(name_question, 30), '...')              AS Вопрос,
       COUNT(is_correct)                                   AS Всего_ответов, 
       ROUND(SUM(is_correct) / COUNT(is_correct) * 100, 2) AS Успешность
FROM testing t INNER JOIN answer a USING (answer_id)
               RIGHT JOIN question q ON q.question_id = a.question_id
               INNER JOIN subject s  ON s.subject_id = q.subject_id
GROUP BY name_subject, name_question 
ORDER BY name_subject, Успешность DESC, name_question;










