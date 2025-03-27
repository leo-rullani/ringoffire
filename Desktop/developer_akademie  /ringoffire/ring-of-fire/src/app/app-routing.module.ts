import { NgModule } from '@angular/core';
import { RouterModule, Routes } from '@angular/router';
import { StartscreenComponent } from './startscreen/startscreen.component';
import { GameComponent } from './game/game.component';


const routes: Routes = [
  {path: '', component: StartscreenComponent },
  {path: 'game', component: GameComponent },
];

@NgModule({
  imports: [RouterModule.forRoot(routes)],
  exports: [RouterModule]
})
export class AppRoutingModule { }
