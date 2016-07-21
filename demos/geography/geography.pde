
ArrayList<Point> points = new ArrayList<Point>();
float x_offset, x_width, y_offset, y_height;

void setup() {
  Table table = loadTable("../../data/constituents.csv", "header");
  size(1080, 720, P3D);

  x_offset = width * 0.025;
  x_width = min(width, 1080) - x_offset * 2;
  y_offset = height * 0.075;
  y_height = min(height, 720) - y_offset * 2;

  for (TableRow r : table.rows()) {
    points.add(new Point(r.getFloat("Longitude"), r.getFloat("Latitude"), 0.0));
  }
}


void draw() {
  background(0);
  noFill();
  stroke(200, 200, 200);
  rect(x_offset, y_offset, x_width, y_height, 7);
  for (Point p : points) {
    float x = 0;
    if (p.x < -60) {
      x = map(p.x, -124, -60, 0, x_width * 0.65);
    } else {
      x = map(p.x, -20, 9, x_width * 0.75, x_width);
    }

    // leave 10% x for the ocean, remove the rest
    float y = map(p.y, 54, 12, 0, y_height);
    stroke(0, 200, 200);
    ellipse(x + x_offset, y + y_offset, 25, 25);
  }
}

class Point {

  Point(float initX, float initY, float initZ) {
    x = initX;
    y = initY;
    z = initZ;
  }

  float x;
  float y;
  float z;
}