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
import java.util.Collections;

class Geography extends Screen {
  private int state_index = 0;
  // transition stage between scenes
  private float[] state_times = new float[] {1500, 8500, 750, 2500, 750};
  // Linear transition, wait, grow radius, wait
  private float state_time = 0.0;
  // Current time on this state
  private float WorldRadius = 200.0;
  private int EntityRadiusLowerBound = 3;
  private int EntityRadiusUpperBound = 15;
  private int pivot = 0;

  PVector cameraEye, cameraCenter;
  float cameraInitialX = sin(EntityTransitions.TransitionSteps[2] * -PI) * 400;
  float cameraInitialY = -WorldRadius;
  float cameraInitialZ = cos(EntityTransitions.TransitionSteps[2] * -PI) * 400;

  private float[] entity_transition_times;
  // How long should each item spend moving

  public Geography() {
    super("Geography", 14000);
    // Duration = Sum of state_times
  }

  void setup(ScreenManager screen_manager) {
    super.setup(screen_manager);
    this.screens_next = new Screen[] {new Sector2d()};
    this.screens_chance = new int[] {100};
    this.entity_transition_times = new float[this.screen_manager.entities.size()];
    Collections.sort(this.screen_manager.entities);
    for (int i = 0; i < this.entity_transition_times.length; i++) {
      this.entity_transition_times[i] = 5.5 * i;
    }

    if (this.screen_manager.orbitalCamera.is_default()) {
      // if our camera is ready, advance
      this.state_index++;
      this.elapsed += this.state_times[0];
    } else {
      this.cameraEye = this.screen_manager.orbitalCamera.eye();
      this.cameraCenter = this.screen_manager.orbitalCamera.center();
    }
  }

  void update_and_draw(float delta, boolean is_paused) {
    if (!is_paused) {
      super.update(delta);
      this.state_time += delta;
    }
     if (this.state_index == 0) {
        if (!is_paused) {
          println(this.state_time, this.state_times[this.state_index], this.screen_manager.orbitalCamera.eye(), this.screen_manager.orbitalCamera.center());
          println(this.cameraEye.x, cameraInitialX - this.cameraEye.x, EntityTransitions.LINEAR.calcEasing(this.state_time, this.cameraEye.x, cameraInitialX - this.cameraEye.x, this.state_times[this.state_index]));
          println(this.cameraEye.y, cameraInitialY - this.cameraEye.y, EntityTransitions.LINEAR.calcEasing(this.state_time, this.cameraEye.y, cameraInitialY - this.cameraEye.y, this.state_times[this.state_index]));
          println(this.cameraEye.z, cameraInitialZ - this.cameraEye.z, EntityTransitions.LINEAR.calcEasing(this.state_time, this.cameraEye.z, cameraInitialZ - this.cameraEye.z, this.state_times[this.state_index]));
        }
        float eyeX = EntityTransitions.LINEAR.calcEasing(this.state_time, this.cameraEye.x, cameraInitialX - this.cameraEye.x, this.state_times[this.state_index]);
        float eyeY = EntityTransitions.LINEAR.calcEasing(this.state_time, this.cameraEye.y, cameraInitialY - this.cameraEye.y, this.state_times[this.state_index]);
        float eyeZ = EntityTransitions.LINEAR.calcEasing(this.state_time, this.cameraEye.z, cameraInitialZ - this.cameraEye.z, this.state_times[this.state_index]);
        float centerX = EntityTransitions.LINEAR.calcEasing(this.state_time, this.cameraCenter.x, -this.cameraCenter.x, this.state_times[this.state_index]);
        float centerY = EntityTransitions.LINEAR.calcEasing(this.state_time, this.cameraCenter.y, -this.cameraCenter.y, this.state_times[this.state_index]);
        float centerZ = EntityTransitions.LINEAR.calcEasing(this.state_time, this.cameraCenter.z, -this.cameraCenter.z, this.state_times[this.state_index]);
        this.screen_manager.orbitalCamera.update(eyeX, eyeY, eyeZ, 0,0,0);
     } 
    for (int i = 0; i < this.screen_manager.entities.size(); i++) {
      Entity e = this.screen_manager.entities.get(i);
      if (!is_paused) {
        if (this.state_index == 0) {
          e.radius = 3.0;
          e.rotation = new Rotation(0.0, 0.0, 0.0);
          e.rotationIncrement = new Rotation(0.0, 0.0, 0.0);
        } else if (this.state_index == 1) {
          // Moving entities
          float latitude = random(e.latitude - 0.01, e.latitude + 0.01) * PI / 180.0;
          float longitude = random(e.longitude - 0.01, e.longitude + 0.01) * PI / 180.0;
          float x = -WorldRadius * cos(latitude) * cos(longitude);
          float y = -WorldRadius * sin(latitude);
          float z = WorldRadius * cos(latitude) * sin(longitude);

          float t = this.state_time > this.entity_transition_times[i] ? this.state_time - this.entity_transition_times[i] : 0.0;
          float d = this.state_times[this.state_index] - this.entity_transition_times[i];
          d = d < t ? t : d;
          e.position.x = EntityTransitions.CUBIC_IN_OUT.calcEasing(t, e.initPosition.x, x, d);
          e.position.y = EntityTransitions.CUBIC_IN_OUT.calcEasing(t, e.initPosition.y, y, d);
          e.position.z = EntityTransitions.CUBIC_IN_OUT.calcEasing(t, e.initPosition.z, z, d);
        } else if (this.state_index == 3) {
          // Growing entities
          float cap = map(e.capitalization, 0.0, 550, EntityRadiusLowerBound, EntityRadiusUpperBound);
          e.radius = EntityTransitions.BOUNCE_IN_OUT.calcEasing(this.state_time, 3.0, cap - 3.0, this.state_times[this.state_index]);
        }
      }
      e.draw();
    }

    if (!is_paused) {
      if(this.state_index > 0) {
        pivot += 2;
      }
    }

    if (pivot < EntityTransitions.MaxTransitionStep - 2) {
      this.screen_manager.orbitalCamera.orbitalUpdate(pivot, 400, -WorldRadius);
    }

    if (!is_paused && this.state_time > this.state_times[this.state_index]) {
      this.state_index++;
      this.state_time = 0.0;
    }
  }
}