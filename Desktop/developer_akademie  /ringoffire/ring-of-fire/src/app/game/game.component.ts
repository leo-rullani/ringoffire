import { Component, OnInit } from '@angular/core';
import { Game } from 'src/models/game';
import { MatDialog } from '@angular/material/dialog';
import { DialogAddPlayerComponent } from '../dialog-add-player/dialog-add-player.component';

import {
  Firestore,
  collection,
  collectionData,
  addDoc
} from '@angular/fire/firestore'; // 🔥 ALLES AUS @angular/fire/firestore

@Component({
  selector: 'app-game',
  templateUrl: './game.component.html',
  styleUrls: ['./game.component.scss']
})
export class GameComponent implements OnInit {
  pickCardAnimation = false;
  currentCard: string = '';
  game: Game;

  constructor(private firestore: Firestore, public dialog: MatDialog) {}

  ngOnInit(): void {
    this.newGame();

    const gamesRef = collection(this.firestore, 'games');

    collectionData(gamesRef, { idField: 'id' }).subscribe((games) => {
      console.log('Game update:', games);
    });
  }

  newGame() {
    this.game = new Game();
    const gamesCollection = collection(this.firestore, 'games');
    addDoc(gamesCollection, { ...this.game.toJson() });
  }

  takeCard() {
    if (!this.pickCardAnimation) {
      this.currentCard = this.game.stack.pop();
      this.pickCardAnimation = true;
      console.log('New Card:', this.currentCard);
      console.log('Game is:', this.game);

      this.game.currentPlayer++;
      this.game.currentPlayer = this.game.currentPlayer % this.game.players.length;

      setTimeout(() => {
        this.game.playedCards.push(this.currentCard);
        this.pickCardAnimation = false;
      }, 1000);
    }
  }

  openDialog(): void {
    const dialogRef = this.dialog.open(DialogAddPlayerComponent);

    dialogRef.afterClosed().subscribe((name) => {
      if (name && name.length > 0) {
        this.game.players.push(name);
      }
    });
  }
}
