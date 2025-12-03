-- PROJECT 
-- THE SITUATION: You and your business partner were recently approached by another local business owner who is interested
-- in purchasing Maven movies. He primarily owns restaurants and bars, so he has a lot of questions for you
-- about your business and the rental business in general. His offer seems very generous, so you are going to
-- entertain his questions.    

-- THE OBJECTIVE: Use MYSQL to leverage your SQL skills to extract and analyze data from various tables in the Maven Movies database
-- to answer your potential acquirer's questions.

-- Question1: My partner and i want to come by each of the stores in person and meet the managers. Please send over the managers'
-- names at each store, with the full address of each property (street address, district, city and country. 

use mavenmovies;
SELECT CONCAT(first_name, " ",last_name) AS full_name, address, district, city, country
FROM staff AS sta
	LEFT OUTER JOIN store AS sto ON sta.store_id=sto.store_id
	LEFT OUTER JOIN address AS adr ON sta.address_id=adr.address_id
	LEFT OUTER JOIN city AS ct ON ct.city_id=adr.city_id
    LEFT OUTER JOIN country AS cn ON cn.country_id=ct.country_id;
    
-- Question2: I would like to get a better understanding of all the inventory that would come along with the business. Please pull
-- together a list of each inventory item you have stocked, including the store_id number, the inventory_id, the name of the film
-- the film's rating, it's rental rate and replacement cost.  

use mavenmovies;
SELECT inv.store_id, inv.inventory_id, f.title, f.rating, f.rental_rate, f.replacement_cost
FROM inventory AS inv
	LEFT OUTER JOIN film AS f ON inv.film_id=f.film_id;

-- Question3: From the same list of fields you just pulled, please roll that data up and provide a summary level overview of your 
-- inventory. We would like to know how many inventory items you have with each rating at each store.

use mavenmovies;
SELECT inv.store_id, f.rating, count(inv.inventory_id) as inventory_items
FROM inventory AS inv
	LEFT OUTER JOIN film AS f ON inv.film_id=f.film_id
GROUP BY inv.store_id, f.rating
ORDER BY inventory_items DESC;

-- Question4: Similarly, we want to understand how diversified the inventory is in terms of replacement cost. We want to see how
-- big of a hit it would be if a certain category of film became unpopular at a certain store. We would like to see the number
-- of films, as well as the average replacement cost, and total replacement cost, sliced by store and film category.

use mavenmovies;
SELECT inv.store_id, c.name, COUNT(f.film_id) as number_of_films, AVG(replacement_cost) AS avg_replac_cost, SUM(replacement_cost) AS total_replac_cost
FROM film AS f
	LEFT OUTER JOIN film_category AS fc ON fc.film_id=f.film_id
	LEFT OUTER JOIN category AS c ON c.category_id=fc.category_id
    LEFT OUTER JOIN inventory AS inv ON inv.film_id=f.film_id
    GROUP BY inv.store_id, c.name
    ORDER BY total_replac_cost DESC;

-- Question5: We want to make sure you folks have a good handle on who your customers are. Please provide a list with all customer 
-- names, which store they go to, whether or not they are currently active, and their full addresses- street address, city & country.

use mavenmovies;
SELECT CONCAT(cust.first_name, " ",cust.last_name) as full_name, adr.address,ct.city,cn.country, cust.store_id, cust.active
FROM customer AS cust
	LEFT OUTER JOIN address as adr  ON cust.address_id=adr.address_id
	LEFT OUTER JOIN city as ct  ON adr.city_id=ct.city_id
	LEFT OUTER JOIN country as cn ON cn.country_id=ct.country_id;

-- Question6: We would like to understand how much your customers are spending with you, and also to know who your most valuable customers
-- are. Please pull together a list of customer names, their total lifetime rentals, and the sum of all payments you have collected from
-- them. It would be great to see this ordered on total lifetime value, with the most valuable customers at the top of the list. 

use mavenmovies;
SELECT CONCAT(cust.first_name, " ",cust.last_name) as full_name, count(rent.rental_id) as customer_lifetime_rentals, 
			sum(paym.amount) AS total_lifetime_customer_payments
FROM customer AS cust
	LEFT OUTER JOIN rental AS rent ON cust.customer_id=rent.customer_id
	LEFT OUTER JOIN payment AS paym ON paym.rental_id=rent.rental_id
GROUP BY full_name
ORDER BY total_lifetime_customer_payments DESC;

-- Question7: My partner and i would like to get to know your board of advisors and any current investors. Could you please provide a list
-- of advisor and investor names in one table? Could you please note whether they are an investor or advisor, and for the investors it would
-- be great to include which company they work with.

use mavenmovies;
SELECT 'advisor' AS type,first_name,last_name, NULL AS company_name FROM advisor
UNION
SELECT 'investor' AS type,first_name,last_name, company_name FROM investor;

-- Question8: We are interested in how well you have covered the most awarded actors. Of all the actors with three types of awards, for what %
-- of them do we carry a film? And how about for actors with two types of awards? Same questions. Finally, how about actors with just one award?

use mavenmovies;
SELECT
	CASE
		WHEN TRIM(aw.awards) = 'Emmy, Oscar, Tony' THEN '3 awards'
		WHEN TRIM(aw.awards) IN ('Emmy, Oscar','Emmy,Tony','Oscar,Tony') THEN '2 awards'
        ELSE '1 award'
        END AS number_of_awards,
        AVG(CASE WHEN aw.actor_id IS NULL THEN 0 ELSE 1 END) AS percentage_of_actors_with_one_film 
FROM actor_award AS aw
GROUP BY 
	CASE 
		WHEN TRIM(aw.awards) = 'Emmy, Oscar, Tony' THEN '3 awards'
		WHEN TRIM(aw.awards) IN ('Emmy, Oscar','Emmy,Tony','Oscar,Tony') THEN '2 awards'
        ELSE '1 award'
        END
