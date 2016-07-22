class ScreenManager {
  Screen screen;
    // Active screen being displayed
  int entity_count = 0;
    // Sets max entities to create

  private ArrayList<Entity> entities = new ArrayList<Entity>();
    // Our main items to transition between Screens

  ScreenManager(Screen screen) {
    this.screen = screen;
  }

  ScreenManager(int entity_count, Screen screen) {
    this.entity_count = entity_count;
    this.screen = screen;
  }

  void setup() {
    Table table = loadTable("../../data/constituents.csv", "header");
    int i = 0;
    for (TableRow row : table.rows()) {
      float x = random(200);
      x = x < 100 ? x * -1 : x - 100 + width;
      //TODO: too far reaching - display should be passed in
      float y = random(200);
      y = y < 100 ? y * -1 : y - 100 + height;
        // Place entities outside of the display
      
      this.entities.add(new Entity(
        row.getString("Symbol"),
        row.getString("Name"),
        row.getString("Sector"),
        row.getString("Industry"),
        row.getFloat("Longitude"),
        row.getFloat("Latitude"),
        x, y, 0.0
        //0.0, 0.0, 0.0
      ));
      this.entities.get(i).screen_update();
      i++;
      if (this.entity_count > 0 && i >= this.entity_count) {
        break;
      }
    }

    this.screen.setup(entities);
  }

  void update(float delta) {
    this.screen.update_and_draw(delta);
    if (this.screen.is_time_elapsed()) {
      //this.screen.teardown();
      this.entities = this.screen.entities;
      for (Entity e : this.entities) {
        e.screen_update(); 
      }
      this.screen = this.screen.screen_next();
      this.screen.setup(this.entities);
    }
  }
}