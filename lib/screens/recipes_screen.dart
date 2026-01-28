import 'package:get/get.dart';
import 'package:diplomka/model/recipe.dart';
import 'package:diplomka/controller/recipe_service.dart';
import 'package:flutter/material.dart';

import 'package:diplomka/controller/base_controller.dart';
import 'package:diplomka/widgets/recipe_card.dart';

class RecipesScreen extends GetView<_RecipesScreenController> {
  const RecipesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GetBuilder<_RecipesScreenController>(
        init: _RecipesScreenController(),
        builder: (_RecipesScreenController controller) {
          return Scaffold(
            backgroundColor: theme.brightness == Brightness.dark ? Colors.black : Colors.grey[100],
            appBar: AppBar(
              title: const Text('Recipes'),
              backgroundColor: theme.brightness == Brightness.dark ? Colors.grey[900] : theme.appBarTheme.backgroundColor,
              elevation: theme.brightness == Brightness.dark ? 0 : 1,
              actions: <Widget>[
                IconButton(
                  icon: const Icon(Icons.tune_rounded),
                  onPressed: () {
                    // TODO: Implement filter/sort functionality by calling controller methods
                  },
                ),
              ],
            ),
            body: Obx(() {
              if (controller.isLoading.isTrue) {
                return const Center(child: CircularProgressIndicator());
              }
              return CustomScrollView(
                slivers: <Widget>[
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Find and filter recipes',
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: theme.brightness == Brightness.dark ? Colors.grey[800] : Colors.white,
                          contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                        ),
                        onChanged: (query) {
                          // TODO: Implement search functionality by calling controller methods
                          // controller.searchRecipes(query);
                        },
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0), // Padding around the grid
                    sliver: SliverGrid(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2, // Number of columns in the grid
                        mainAxisSpacing: 0, // Spacing between rows
                        crossAxisSpacing: 0, // Spacing between columns
                        childAspectRatio: 0.82, // Aspect ratio of grid items (width / height) - adjust as needed
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (BuildContext context, int index) {
                          final recipe = controller.recipes[index];
                          return RecipeCard(recipe: recipe);
                        },
                        childCount: controller.recipes.length,
                      ),
                    ),
                  ),
                ],
              );
            }),
          );
        });
  }
}

class _RecipesScreenController extends BaseController {
  final RecipeService _recipeService = Get.find<RecipeService>();
  final RxList<Recipe> recipes = <Recipe>[].obs;
  final RxBool isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    _fetchRecipes();
  }

  Future<void> _fetchRecipes() async {
    try {
      isLoading.value = true;
      final fetchedRecipes = await _recipeService.getRecipes();
      recipes.assignAll(fetchedRecipes);
    } catch (e) {
      // Handle error, e.g., show a snackbar or an error message
      print("Error fetching recipes: $e");
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onHidden() {
    // TODO: implement onHidden
  }
}
