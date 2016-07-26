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
import de.looksgood.ani.AniConstants;

static class EntityTransitions implements AniConstants {
  static color[] Colors = {#a6cee3, #1f78b4, #b2df8a, #33a02c, #fb9a99, #e31a1c, #fdbf6f, #ff7f00, #cab2d6, #6a3d9a};
  static float ZeroMarketSize = 200; // Radius of the nominal universe
  static float AngleBoundary = 2.2;
  static float AngularRotationBoundary = 0.003;
  static int TrailCount = 10;
  static float TransitioningStep = 0.001;
  static int MaxTransitionStep = int(1 / TransitioningStep);
  static float[] TransitionSteps = new float[MaxTransitionStep];
  
}