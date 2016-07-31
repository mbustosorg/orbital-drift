

import java.util.Date;
import java.text.SimpleDateFormat;

String endpoint = "http://download.finance.yahoo.com/d/quotes.csv";
String fields = "f=s,n,j1,d1,t1,p2,v,a2";
String symbols = "s=MMM,ABT,ABBV";
void setup() {
  String url = endpoint + "?" + fields + "&" + symbols;
  println(url);
  
  String lines[] = loadStrings(url);
  println("there are " + lines.length + " lines");
  for (int i = 0 ; i < lines.length; i++) {
    println(lines[i]);
  }
  
  
  SimpleDateFormat formatter = new SimpleDateFormat("M/d/yyyy h:mma");
  Table t = loadTable(url, "csv");
  for (TableRow row : t.rows()) {
    try {
    println(
      row.getString(6),
      row.getString(8),
      formatter.parse(row.getString(6) + " " + row.getString(8)).toString()
    );
    } catch (Exception e) {
      println (e);
    }
    
    
    String symbol = row.getString(0);
    String name = row.getString(2);
    String capt = row.getString(4);
    println(symbol + " (" + name + ") has capt of " + capt);
  }
}


void draw() {
  
}