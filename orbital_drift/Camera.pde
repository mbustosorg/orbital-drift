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

class Camera {
  float eyeX, eyeY, eyeZ;
  float centerX, centerY, centerZ;
  float upX, upY, upZ;

  final float eyeXdefault = width / 2.0, eyeYdefault = height / 2.0, eyeZdefault = (height/2.0) / tan(PI*30.0 / 180.0);
  final float centerXdefault = width / 2.0, centerYdefault = height / 2.0, centerZdefault = 0.0;

  Camera() {
    this.eyeX = width / 2.0;
    this.eyeY = height / 2.0;
    this.eyeZ = (height/2.0) / tan(PI*30.0 / 180.0);
    this.centerX = width / 2.0;
    this.centerY = height / 2.0;
    this.centerZ = 0;
    this.upX = 0;
    this.upY = 1;
    this.upZ = 0;
  }

  boolean is_default() {
    return this.eyeX == eyeXdefault && 
      this.eyeY == eyeYdefault &&
      this.eyeZ == eyeZdefault &&
      this.centerX ==centerXdefault &&
      this.centerY == centerYdefault &&
      this.centerZ == centerZdefault;
  }

  void update(float eyeX, float eyeY, float eyeZ) {
    update(eyeX, eyeY, eyeZ, 0, 0, 0); 
  }

  void update(float eyeX, float eyeY, float eyeZ, float centerX, float centerY, float centerZ) {
    update(eyeX, eyeY, eyeZ, centerX, centerY, centerZ, 0, 1, 0);
  }

  void update(float eyeX, float eyeY, float eyeZ, float centerX, float centerY, float centerZ, float upX, float upY, float upZ) {
    // Wrapper so we can capture the last instruction
    this.eyeX = eyeX;
    this.eyeY = eyeY;
    this.eyeZ = eyeZ;
    this.centerX = centerX;
    this.centerY = centerY;
    this.centerZ = centerZ;
    this.upX = upX;
    this.upY = upY;
    this.upZ = upZ;

    camera(eyeX, eyeY, eyeZ, centerX, centerY, centerZ, upX, upY, upZ);
  }
  
  void orbitalUpdate(int transition_step, float dependent, float independent) {
    update(sin(EntityTransitions.TransitionSteps[transition_step] * -PI) * dependent, independent, cos(EntityTransitions.TransitionSteps[transition_step] * -PI) * dependent);
  }
  
  PVector eye(){
    return new PVector(this.eyeX, this.eyeY, this.eyeZ); 
  }

  PVector center(){
    return new PVector(this.centerX, this.centerY, this.centerZ); 
  }
}