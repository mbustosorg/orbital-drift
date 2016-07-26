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

class Label {
  String message;
  PVector position;
  Camera orbitalCamera;

  Label(PVector position, String message, Camera orbitalCamera) {
    this.message = message;
    this.position = position;
    this.orbitalCamera = orbitalCamera;
  }

  Label(PVector position, Camera orbitalCamera) {
    this(position, new String(""), orbitalCamera);
  }

  void draw() {
    draw(null); 
  }

  void draw(String message_override) {
    pushStyle();
    int textSize = 12;
    textSize(textSize);
    pushMatrix();
    if (this.orbitalCamera != null) {
      PVector eye = this.orbitalCamera.eye();
      // Rotate to face
      rotateY(-atan2(eye.z, eye.x) + PI / 2);
      rotateX(-atan2(eye.y, eye.mag()));
    }

    text(message_override.isEmpty() ? message : message_override, this.position.x, this.position.y, this.position.z);
    popMatrix();
    popStyle();
  }
}