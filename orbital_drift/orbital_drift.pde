/* //<>//

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

ScreenManager screen_manager = new ScreenManager(new Geography());
  // Handles change over of screens and entities
float draw_last_millis;
  // Determine delta between frames

void setup() {
  size(1000, 1000, P3D);
  screen_manager.setup();
  draw_last_millis = millis();
}

void draw() {
  background(0);
  lights();
  float draw_millis = millis();
  screen_manager.update(draw_millis - draw_last_millis);
  textSize(32);
  fill(150);
  text(
    String.format("Screen '%s', %.3f / %.1f", screen_manager.screen.name, screen_manager.screen.elapsed , screen_manager.screen.duration),
    width * 0.25,
    height * 0.75,
    0.0);
  draw_last_millis = draw_millis;
}

void keyPressed() {
  screen_manager.keyPressed();
}