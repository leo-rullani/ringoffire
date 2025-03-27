import { Component } from '@angular/core';
import { Router } from '@angular/router';

@Component({
  selector: 'app-startscreen',
  templateUrl: './startscreen.component.html',
  styleUrls: ['./startscreen.component.scss']
})
export class StartscreenComponent {

constructor(private router: Router) {}

  newGame() {
    // Start game
    this.router.navigateByUrl('/game');
  }

}
