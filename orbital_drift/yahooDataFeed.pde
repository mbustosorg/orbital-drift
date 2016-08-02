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

import java.util.Date;
import java.text.SimpleDateFormat;
import java.lang.Thread;

class YahooDataFeed {
  String endpoint = "http://download.finance.yahoo.com/d/quotes.csv?";
  String fields = "f=s,n,j1,d1,t1,p2,v,a2&";
  String symbol = "s=";
  Integer querySymbolLimit = 500;

  String feedSaveDirectory = dataPath("ticker") + "/";

  YahooDataFeed() {
      // Cleanup debug file directory
    File dir = new File(feedSaveDirectory);
    if (dir.exists()) {
      File[] files = dir.listFiles();
      if (files != null) {
        for (int i = 0; i < files.length; i++) {
          files[i].delete();
        }
      }
    }
  }

  ArrayList<TickerData> data_by_entities(ArrayList<Entity> entities) {
    ArrayList<String> symbols = new ArrayList<String>();
    for (Entity e : entities) {
      if (!e.exchange.equals("TSE")) {
        // No data feed for Japan yet
        symbols.add(e.symbol);
      }
    }

    ArrayList<TickerData> tickerData = new ArrayList<TickerData>();
    for (int s = 0; s <= (int)(symbols.size() / querySymbolLimit); s++) {
      String symbol = new String();
      Integer upperLimit = min(symbols.size() - 1, (s + 1) * 500);
      for (int i = s * 500; i < upperLimit; i++) {
        symbol += symbols.get(i) + ",";
      }

      try {
        Thread.sleep(100);
      } catch (Exception e) { }
      tickerData.addAll(data_by_symbols(symbol.substring(0, symbol.length() - 1)));
    }

    return tickerData;
  }

  ArrayList<TickerData> data_by_symbols(String symbols) {
    ArrayList<TickerData> tickerData = new ArrayList<TickerData>();
    String url = endpoint + fields + symbol + symbols;
    println("  datafeed: yahoo.finance", symbols.length());
    try {
      SimpleDateFormat formatter = new SimpleDateFormat("M/d/yyyy h:mma");
      SimpleDateFormat requestFormat = new SimpleDateFormat("yyyyMMdd_kkmmssSSS");
      Table t = loadTable(url, "csv");
      saveTable(t, feedSaveDirectory + requestFormat.format(new Date()) + ".csv", "csv");
      for (TableRow row : t.rows()) {
        String cap = row.getString(4);
        float capt = 0.0;
        
        if (!cap.equals("N/A")) {
          capt = Float.parseFloat(cap.substring(0, cap.length() - 1));
          if (cap.charAt(cap.length() - 1) == 'M') {
            capt /= 1000;
          }
        }
        
        if (capt < 0.0 || capt > 600) {
          println("!! yahooDataFeed Capt Boundaries", capt, row.getString(0));
        }
        
        Date lastTradeDate = null;
        String datePart = row.getString(6);
        String timePart = row.getString(8);
        if (!datePart.equals(timePart)) {
          lastTradeDate = formatter.parse(row.getString(6) + " " + row.getString(8));
        }

        tickerData.add(new TickerData(
          row.getString(0),
          row.getString(2),
          capt,
          lastTradeDate,
          row.getFloat(10),
          row.getInt(12),
          row.getInt(14)
        ));
      }
    } catch (Exception e) {
      println(e);
    }
    return tickerData;
  }
  
}

class TickerData {
  String symbol, name;
  float capitalizationB;
  Date lastTradeDate;
  float dayChangePercentage;
  Integer volumeDay, volumeAvg;

  TickerData(String symbol, String name, float capitalizationB, Date lastTradeDate, float dayChangePercentage, Integer volumeDay, Integer volumeAvg) {
    this.symbol = symbol;
    this.name = name;
    this.capitalizationB = capitalizationB;
    this.lastTradeDate = lastTradeDate;
    this.dayChangePercentage = dayChangePercentage;
    this.volumeDay = volumeDay;
    this.volumeAvg = volumeAvg;
  }
}