/*

 Copyright (C) 2016 Mauricio Bustos (m@bustos.org), Matthew Yeager
 
 This program is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.
 
 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.
 
 You should have received a copy of the GNU General Public License
 along with this program.  If not, see <http://www.gnu.org/licenses/>.
 
 */

class ScreenManager {
  YahooDataFeed datafeed = new YahooDataFeed();
  ArrayList<TickerData> tickerData = new ArrayList<TickerData>();
  // New information to push to entities
  float tickerUpdateRate = 5 * 60 * 1000.00, tickerUpdateElapsed = 0.0;
  // 5 minutes * 60 seconds * 1000 millis
  float tickerDataPushRate, tickerDataPushElapsed = 0.0;
  // How often do we push data to entities

  HashMap<String, ArrayList<Entity>> entities_by_index = new HashMap<String, ArrayList<Entity>>();
  // Entity grouping showing all possible options going into `entities'
  ArrayList<Entity> entities = new ArrayList<Entity>();
  // Our main items to transition between Screens

  IntDict sector_to_id = new IntDict(new Object[][] {
    { "Consumer Discretionary", 0}, 
    { "Consumer Staples", 1}, 
    { "Energy", 2}, 
    { "Financials", 3}, 
    { "Health Care", 4}, 
    { "Industrials", 5}, 
    { "Information Technology", 6}, 
    { "Materials", 7}, 
    { "Telecommunication Services", 8}, 
    { "Utilities", 9}
    });
  float totalCapitalization = 0.0;
  // Lookup from Sector to allow for lookups for color or partition
  color[] sector_colors = {#a6cee3, #1f78b4, #b2df8a, #33a02c, #fb9a99, #e31a1c, #fdbf6f, #ff7f00, #cab2d6, #6a3d9a};
  // established for use across screens
  ArrayList<ArrayList<Entity>> entities_by_sector = new ArrayList<ArrayList<Entity>>();
  // Entities partitioned by sector
  Camera orbitalCamera = new Camera();

  private HashMap<String, Entity> symbol_to_entity = new HashMap<String, Entity>();

  private Label debugLabel;

  private Screen screen;
  // Active screen being displayed
  private boolean is_paused = false;

  ScreenManager(Screen screen) {
    this.screen = screen;
    for (int i = 0; i < this.sector_to_id.size(); i++) {
      this.entities_by_sector.add(new ArrayList<Entity>());
    }
    for (int i = 0; i < 1 / EntityTransitions.TransitioningStep - 1; i++) {
      float step = float(i) / (1.0 / EntityTransitions.TransitioningStep / 2.0);
      if (step < 1) {
        EntityTransitions.TransitionSteps[i] = step * step * step / 2.0;
      } else {
        step -= 2;
        EntityTransitions.TransitionSteps[i] = (step * step * step + 2) / 2.0;
      }
    }
  }

  void keyPressed() {
    if (key == 'p') {
      this.is_paused = !this.is_paused;
    }
    screen.keyPressed();
  }

  void setup() {
    String datapath = dataPath("index/");
    File dataDirectory = new File(datapath);
    String[] fileNames = dataDirectory.list();

    debugLabel = new Label(new PVector(-width / 4, -height / 4 + 12 + 475, 0), this.orbitalCamera);

    for (String filename : fileNames) {
      print(filename);
      Table table = loadTable(datapath + "/" + filename, "header");
      println(":", table.getColumnCount(), "x", table.getRowCount());
      ArrayList<Entity> entity_index = new ArrayList<Entity>();
      for (TableRow row : table.rows()) {
        if (!this.sector_to_id.hasKey(row.getString("Sector"))) {
          println("!! Unknown Sector", row.getString("Symbol"));
        }

        Entity e = new Entity(
          row.getString("Exchange"), 
          row.getString("Symbol"), 
          row.getString("Name"), 
          row.getString("Sector"), 
          this.sector_to_id.get(row.getString("Sector")), 
          row.getString("Industry"), 
          0.0, 
          row.getFloat("Longitude"), 
          row.getFloat("Latitude"), 
          0.0, 0.0, 0.0, 
          new Rotation(0.0, 0.0, 0.0), new Rotation(0.0, 0.0, 0.0)
          );
        e.screen_update();
        symbol_to_entity.put(e.symbol, e);  
        entity_index.add(e);
        this.entities_by_sector.get(this.sector_to_id.get(e.sector)).add(e);
      }

      this.entities_by_index.put(filename.substring(0, filename.indexOf('.')), entity_index);
      this.entities.addAll(entity_index);
    }

    this.tickerData = datafeed.data_by_entities(this.entities);
    println ("ArrayList<TickerData>", this.tickerData.size());
    for (TickerData t : this.tickerData) {
      Entity e = this.symbol_to_entity.get(t.symbol);
      if (e != null) {
        e.capitalization = t.capitalizationB;
        EntityTransitions.SectorToCapRatio.set(e.sector, EntityTransitions.SectorToCapRatio.get(e.sector) + e.capitalization);
        totalCapitalization += e.capitalization;
      } else {
        println("No entity found for symbol", t.symbol);
      }
    }

    println("Total Captialization ($B): " + totalCapitalization);
    for (String key : EntityTransitions.SectorToCapRatio.keys()) {
      EntityTransitions.SectorToCapRatio.set(key, EntityTransitions.SectorToCapRatio.get(key) / totalCapitalization);
      println(String.format("  %05.2f%% - %s", EntityTransitions.SectorToCapRatio.get(key) * 100, key));
    }

    this.tickerDataPushRate = this.tickerUpdateRate / this.entities.size();
    this.screen.setup(this);
  }

  void update(float delta) {
    this.tickerUpdateElapsed += delta;
    if (this.tickerUpdateElapsed >= this.tickerUpdateRate) {
      // Update ticker data 
      this.tickerUpdateElapsed = 0.0;
      thread("tickerDataRequestAndPopulate");
    }

    this.tickerDataPushElapsed += delta;
    if (this.tickerData.size() > 0 && this.tickerDataPushElapsed >= this.tickerDataPushRate) {
      // Push ticker data to entities over `tickerUpdateRate'
      this.tickerDataPushElapsed = 0.0;
      TickerData td = this.tickerData.remove(0);
      Entity e = this.symbol_to_entity.get(td.symbol);
      if (e != null) {
        e.ticker_update(td);
      } else {
        println("!!", "TickerData for unknown entity. Symbol: ", td.symbol);
      }
    }

    this.screen.update_and_draw(delta, this.is_paused);
    if (this.is_paused) {
      fill(150);
      debugLabel.draw(String.format("Screen '%s', %.0f / %.0f", this.screen.name, this.screen.elapsed, this.screen.duration));
    } else {
      //println(frameRate);
    }

    if (this.screen.is_time_elapsed()) {
      this.screen.teardown();
      for (Entity e : this.entities) {
        e.screen_update();
      }
      this.screen = this.screen.screen_next();
      this.screen.setup(this);
    }
  }

  public void entities_update(ArrayList<Entity> new_entities) {
    this.entities = new_entities;
    ArrayList<String> symbols = new ArrayList<String>();
    for (Entity e : this.entities) {
      symbols.add(e.symbol);
    }

    for (int i = this.tickerData.size() - 1; i >= 0; i --) {
      TickerData td = this.tickerData.get(i);
      if (!symbols.contains(td.symbol)) {
        this.tickerData.remove(td);
      }
    }
  }
}