## Анализ поведения покупателей в розничных магазинах

### Описание:

Используя таблицы "store_checkout_queues" и "store_stores" произвести объединение данных по чекам и магазинам, чтобы в результате получить таблицу вида:

checks_number
store_id
employees_id
quantity
selling_price
checkout_id
start_operation_dt
end_operation_dt

Выбрать данные только по магазинам с id=98451680 и id=12864064. На полученной выборке данных произведите расчет, чтобы определить периоды, когда на кассах есть очередь.

---

### Стек:
<p>
	<img src="https://img.shields.io/badge/SQL-DF6C20?style=for-the-badge&logo=mysql&logoColor=white" alt="SQL" />
</p>

---

### Решение:

[Ссылка на файл с решением](https://github.com/MariaKln/queues_at_the_checkout/blob/main/retail_task.sql)