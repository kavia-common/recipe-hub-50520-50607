#!/usr/bin/env bash
# Seed data for categories, recipes, recipe_categories, and recipe_ingredients
# IMPORTANT: Each SQL is executed as a single-statement psql -c command.
# Reads the connection command from ./db_connection.txt per container rules.

set -euo pipefail

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONN_FILE="${BASE_DIR}/db_connection.txt"

if [[ ! -f "${CONN_FILE}" ]]; then
  echo "ERROR: db_connection.txt not found at ${CONN_FILE}"
  echo "Start the database setup first (startup.sh) to create it."
  exit 1
fi

# Read the full psql command (e.g., "psql postgresql://user:pass@host:port/db")
PSQL_CMD="$(cat "${CONN_FILE}" | tr -d '\r')"

echo "Seeding database using: ${PSQL_CMD}"

# 1) Ensure required tables exist (still one statement per command)
${PSQL_CMD} -c "CREATE TABLE IF NOT EXISTS categories (id SERIAL PRIMARY KEY, name TEXT UNIQUE NOT NULL);"
${PSQL_CMD} -c "CREATE TABLE IF NOT EXISTS recipes (id SERIAL PRIMARY KEY, title TEXT NOT NULL, description TEXT, instructions TEXT, image_url TEXT);"
${PSQL_CMD} -c "CREATE TABLE IF NOT EXISTS recipe_categories (recipe_id INT REFERENCES recipes(id) ON DELETE CASCADE, category_id INT REFERENCES categories(id) ON DELETE CASCADE, PRIMARY KEY (recipe_id, category_id));"
${PSQL_CMD} -c "CREATE TABLE IF NOT EXISTS recipe_ingredients (id SERIAL PRIMARY KEY, recipe_id INT REFERENCES recipes(id) ON DELETE CASCADE, ingredient TEXT NOT NULL, normalized_ingredient TEXT NOT NULL);"

# 2) Seed categories (each in its own INSERT)
${PSQL_CMD} -c "INSERT INTO categories (name) VALUES ('Breakfast') ON CONFLICT (name) DO NOTHING;"
${PSQL_CMD} -c "INSERT INTO categories (name) VALUES ('Lunch') ON CONFLICT (name) DO NOTHING;"
${PSQL_CMD} -c "INSERT INTO categories (name) VALUES ('Dinner') ON CONFLICT (name) DO NOTHING;"
${PSQL_CMD} -c "INSERT INTO categories (name) VALUES ('Dessert') ON CONFLICT (name) DO NOTHING;"
${PSQL_CMD} -c "INSERT INTO categories (name) VALUES ('Vegetarian') ON CONFLICT (name) DO NOTHING;"
${PSQL_CMD} -c "INSERT INTO categories (name) VALUES ('Vegan') ON CONFLICT (name) DO NOTHING;"
${PSQL_CMD} -c "INSERT INTO categories (name) VALUES ('Gluten-Free') ON CONFLICT (name) DO NOTHING;"

# 3) Seed recipes (5-10 recipes, each with own INSERT)
${PSQL_CMD} -c "INSERT INTO recipes (title, description, instructions, image_url) VALUES ('Classic Pancakes', 'Fluffy breakfast pancakes.', '1) Mix dry ingredients. 2) Whisk in milk and eggs. 3) Cook on griddle until golden.', 'https://images.example.com/pancakes.jpg');"
${PSQL_CMD} -c "INSERT INTO recipes (title, description, instructions, image_url) VALUES ('Avocado Toast', 'Simple and tasty avocado toast.', 'Toast bread. Mash avocado with salt, pepper, and lemon. Spread and serve.', 'https://images.example.com/avocado_toast.jpg');"
${PSQL_CMD} -c "INSERT INTO recipes (title, description, instructions, image_url) VALUES ('Grilled Chicken Salad', 'Healthy lunch salad with grilled chicken.', 'Grill seasoned chicken. Toss greens, tomatoes, cucumber, and dressing. Slice chicken and top.', 'https://images.example.com/grilled_chicken_salad.jpg');"
${PSQL_CMD} -c "INSERT INTO recipes (title, description, instructions, image_url) VALUES ('Spaghetti Bolognese', 'Classic Italian pasta with meat sauce.', 'Saute onions and garlic. Brown beef. Add tomatoes and simmer. Boil spaghetti and combine.', 'https://images.example.com/spaghetti_bolognese.jpg');"
${PSQL_CMD} -c "INSERT INTO recipes (title, description, instructions, image_url) VALUES ('Veggie Stir-fry', 'Colorful vegetables in a savory sauce.', 'Stir-fry veggies over high heat. Add soy sauce, ginger, and garlic. Serve with rice.', 'https://images.example.com/veggie_stirfry.jpg');"
${PSQL_CMD} -c "INSERT INTO recipes (title, description, instructions, image_url) VALUES ('Chocolate Chip Cookies', 'Chewy chocolate chip cookies.', 'Cream butter and sugar. Mix in eggs and flour. Fold in chips. Bake until golden.', 'https://images.example.com/choc_chip_cookies.jpg');"
${PSQL_CMD} -c "INSERT INTO recipes (title, description, instructions, image_url) VALUES ('Quinoa Bowl', 'Protein-packed quinoa with veggies.', 'Cook quinoa. Roast vegetables. Assemble with dressing and seeds.', 'https://images.example.com/quinoa_bowl.jpg');"
${PSQL_CMD} -c "INSERT INTO recipes (title, description, instructions, image_url) VALUES ('Tomato Soup', 'Comforting tomato soup.', 'Saute onions and garlic. Add tomatoes and broth. Simmer and blend. Serve warm.', 'https://images.example.com/tomato_soup.jpg');"
${PSQL_CMD} -c "INSERT INTO recipes (title, description, instructions, image_url) VALUES ('Chicken Tacos', 'Weeknight chicken tacos.', 'Season and saute chicken. Warm tortillas. Assemble with toppings.', 'https://images.example.com/chicken_tacos.jpg');"
${PSQL_CMD} -c "INSERT INTO recipes (title, description, instructions, image_url) VALUES ('Fruit Parfait', 'Layered yogurt, fruit, and granola.', 'Layer yogurt, berries, and granola in a glass. Drizzle honey.', 'https://images.example.com/fruit_parfait.jpg');"

# 4) Map recipe to categories (one INSERT at a time; use SELECTs to resolve IDs)
${PSQL_CMD} -c "INSERT INTO recipe_categories (recipe_id, category_id) SELECT r.id, c.id FROM recipes r, categories c WHERE r.title='Classic Pancakes' AND c.name='Breakfast' ON CONFLICT DO NOTHING;"
${PSQL_CMD} -c "INSERT INTO recipe_categories (recipe_id, category_id) SELECT r.id, c.id FROM recipes r, categories c WHERE r.title='Avocado Toast' AND c.name='Breakfast' ON CONFLICT DO NOTHING;"
${PSQL_CMD} -c "INSERT INTO recipe_categories (recipe_id, category_id) SELECT r.id, c.id FROM recipes r, categories c WHERE r.title='Grilled Chicken Salad' AND c.name='Lunch' ON CONFLICT DO NOTHING;"
${PSQL_CMD} -c "INSERT INTO recipe_categories (recipe_id, category_id) SELECT r.id, c.id FROM recipes r, categories c WHERE r.title='Spaghetti Bolognese' AND c.name='Dinner' ON CONFLICT DO NOTHING;"
${PSQL_CMD} -c "INSERT INTO recipe_categories (recipe_id, category_id) SELECT r.id, c.id FROM recipes r, categories c WHERE r.title='Veggie Stir-fry' AND c.name='Vegetarian' ON CONFLICT DO NOTHING;"
${PSQL_CMD} -c "INSERT INTO recipe_categories (recipe_id, category_id) SELECT r.id, c.id FROM recipes r, categories c WHERE r.title='Chocolate Chip Cookies' AND c.name='Dessert' ON CONFLICT DO NOTHING;"
${PSQL_CMD} -c "INSERT INTO recipe_categories (recipe_id, category_id) SELECT r.id, c.id FROM recipes r, categories c WHERE r.title='Quinoa Bowl' AND c.name='Vegan' ON CONFLICT DO NOTHING;"
${PSQL_CMD} -c "INSERT INTO recipe_categories (recipe_id, category_id) SELECT r.id, c.id FROM recipes r, categories c WHERE r.title='Tomato Soup' AND c.name='Lunch' ON CONFLICT DO NOTHING;"
${PSQL_CMD} -c "INSERT INTO recipe_categories (recipe_id, category_id) SELECT r.id, c.id FROM recipes r, categories c WHERE r.title='Chicken Tacos' AND c.name='Dinner' ON CONFLICT DO NOTHING;"
${PSQL_CMD} -c "INSERT INTO recipe_categories (recipe_id, category_id) SELECT r.id, c.id FROM recipes r, categories c WHERE r.title='Fruit Parfait' AND c.name='Dessert' ON CONFLICT DO NOTHING;"

# 5) Seed recipe_ingredients with normalized_ingredient (lowercased, trimmed)
# Classic Pancakes
${PSQL_CMD} -c "INSERT INTO recipe_ingredients (recipe_id, ingredient, normalized_ingredient) SELECT r.id, 'Flour', lower(trim('Flour')) FROM recipes r WHERE r.title='Classic Pancakes';"
${PSQL_CMD} -c "INSERT INTO recipe_ingredients (recipe_id, ingredient, normalized_ingredient) SELECT r.id, 'Milk', lower(trim('Milk')) FROM recipes r WHERE r.title='Classic Pancakes';"
${PSQL_CMD} -c "INSERT INTO recipe_ingredients (recipe_id, ingredient, normalized_ingredient) SELECT r.id, 'Eggs', lower(trim('Eggs')) FROM recipes r WHERE r.title='Classic Pancakes';"

# Avocado Toast
${PSQL_CMD} -c "INSERT INTO recipe_ingredients (recipe_id, ingredient, normalized_ingredient) SELECT r.id, 'Avocado', lower(trim('Avocado')) FROM recipes r WHERE r.title='Avocado Toast';"
${PSQL_CMD} -c "INSERT INTO recipe_ingredients (recipe_id, ingredient, normalized_ingredient) SELECT r.id, 'Bread', lower(trim('Bread')) FROM recipes r WHERE r.title='Avocado Toast';"
${PSQL_CMD} -c "INSERT INTO recipe_ingredients (recipe_id, ingredient, normalized_ingredient) SELECT r.id, 'Lemon', lower(trim('Lemon')) FROM recipes r WHERE r.title='Avocado Toast';"

# Grilled Chicken Salad
${PSQL_CMD} -c "INSERT INTO recipe_ingredients (recipe_id, ingredient, normalized_ingredient) SELECT r.id, 'Chicken Breast', lower(trim('Chicken Breast')) FROM recipes r WHERE r.title='Grilled Chicken Salad';"
${PSQL_CMD} -c "INSERT INTO recipe_ingredients (recipe_id, ingredient, normalized_ingredient) SELECT r.id, 'Mixed Greens', lower(trim('Mixed Greens')) FROM recipes r WHERE r.title='Grilled Chicken Salad';"
${PSQL_CMD} -c "INSERT INTO recipe_ingredients (recipe_id, ingredient, normalized_ingredient) SELECT r.id, 'Tomatoes', lower(trim('Tomatoes')) FROM recipes r WHERE r.title='Grilled Chicken Salad';"

# Spaghetti Bolognese
${PSQL_CMD} -c "INSERT INTO recipe_ingredients (recipe_id, ingredient, normalized_ingredient) SELECT r.id, 'Spaghetti', lower(trim('Spaghetti')) FROM recipes r WHERE r.title='Spaghetti Bolognese';"
${PSQL_CMD} -c "INSERT INTO recipe_ingredients (recipe_id, ingredient, normalized_ingredient) SELECT r.id, 'Ground Beef', lower(trim('Ground Beef')) FROM recipes r WHERE r.title='Spaghetti Bolognese';"
${PSQL_CMD} -c "INSERT INTO recipe_ingredients (recipe_id, ingredient, normalized_ingredient) SELECT r.id, 'Tomato Sauce', lower(trim('Tomato Sauce')) FROM recipes r WHERE r.title='Spaghetti Bolognese';"

# Veggie Stir-fry
${PSQL_CMD} -c "INSERT INTO recipe_ingredients (recipe_id, ingredient, normalized_ingredient) SELECT r.id, 'Broccoli', lower(trim('Broccoli')) FROM recipes r WHERE r.title='Veggie Stir-fry';"
${PSQL_CMD} -c "INSERT INTO recipe_ingredients (recipe_id, ingredient, normalized_ingredient) SELECT r.id, 'Bell Pepper', lower(trim('Bell Pepper')) FROM recipes r WHERE r.title='Veggie Stir-fry';"
${PSQL_CMD} -c "INSERT INTO recipe_ingredients (recipe_id, ingredient, normalized_ingredient) SELECT r.id, 'Soy Sauce', lower(trim('Soy Sauce')) FROM recipes r WHERE r.title='Veggie Stir-fry';"

# Chocolate Chip Cookies
${PSQL_CMD} -c "INSERT INTO recipe_ingredients (recipe_id, ingredient, normalized_ingredient) SELECT r.id, 'Butter', lower(trim('Butter')) FROM recipes r WHERE r.title='Chocolate Chip Cookies';"
${PSQL_CMD} -c "INSERT INTO recipe_ingredients (recipe_id, ingredient, normalized_ingredient) SELECT r.id, 'Sugar', lower(trim('Sugar')) FROM recipes r WHERE r.title='Chocolate Chip Cookies';"
${PSQL_CMD} -c "INSERT INTO recipe_ingredients (recipe_id, ingredient, normalized_ingredient) SELECT r.id, 'Chocolate Chips', lower(trim('Chocolate Chips')) FROM recipes r WHERE r.title='Chocolate Chip Cookies';"

# Quinoa Bowl
${PSQL_CMD} -c "INSERT INTO recipe_ingredients (recipe_id, ingredient, normalized_ingredient) SELECT r.id, 'Quinoa', lower(trim('Quinoa')) FROM recipes r WHERE r.title='Quinoa Bowl';"
${PSQL_CMD} -c "INSERT INTO recipe_ingredients (recipe_id, ingredient, normalized_ingredient) SELECT r.id, 'Roasted Veggies', lower(trim('Roasted Veggies')) FROM recipes r WHERE r.title='Quinoa Bowl';"
${PSQL_CMD} -c "INSERT INTO recipe_ingredients (recipe_id, ingredient, normalized_ingredient) SELECT r.id, 'Tahini', lower(trim('Tahini')) FROM recipes r WHERE r.title='Quinoa Bowl';"

# Tomato Soup
${PSQL_CMD} -c "INSERT INTO recipe_ingredients (recipe_id, ingredient, normalized_ingredient) SELECT r.id, 'Tomatoes', lower(trim('Tomatoes')) FROM recipes r WHERE r.title='Tomato Soup';"
${PSQL_CMD} -c "INSERT INTO recipe_ingredients (recipe_id, ingredient, normalized_ingredient) SELECT r.id, 'Onion', lower(trim('Onion')) FROM recipes r WHERE r.title='Tomato Soup';"
${PSQL_CMD} -c "INSERT INTO recipe_ingredients (recipe_id, ingredient, normalized_ingredient) SELECT r.id, 'Vegetable Broth', lower(trim('Vegetable Broth')) FROM recipes r WHERE r.title='Tomato Soup';"

# Chicken Tacos
${PSQL_CMD} -c "INSERT INTO recipe_ingredients (recipe_id, ingredient, normalized_ingredient) SELECT r.id, 'Chicken', lower(trim('Chicken')) FROM recipes r WHERE r.title='Chicken Tacos';"
${PSQL_CMD} -c "INSERT INTO recipe_ingredients (recipe_id, ingredient, normalized_ingredient) SELECT r.id, 'Tortillas', lower(trim('Tortillas')) FROM recipes r WHERE r.title='Chicken Tacos';"
${PSQL_CMD} -c "INSERT INTO recipe_ingredients (recipe_id, ingredient, normalized_ingredient) SELECT r.id, 'Salsa', lower(trim('Salsa')) FROM recipes r WHERE r.title='Chicken Tacos';"

# Fruit Parfait
${PSQL_CMD} -c "INSERT INTO recipe_ingredients (recipe_id, ingredient, normalized_ingredient) SELECT r.id, 'Yogurt', lower(trim('Yogurt')) FROM recipes r WHERE r.title='Fruit Parfait';"
${PSQL_CMD} -c "INSERT INTO recipe_ingredients (recipe_id, ingredient, normalized_ingredient) SELECT r.id, 'Berries', lower(trim('Berries')) FROM recipes r WHERE r.title='Fruit Parfait';"
${PSQL_CMD} -c "INSERT INTO recipe_ingredients (recipe_id, ingredient, normalized_ingredient) SELECT r.id, 'Granola', lower(trim('Granola')) FROM recipes r WHERE r.title='Fruit Parfait';"

echo "Seeding complete."
