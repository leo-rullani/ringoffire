import { Component, Input, OnChanges, OnInit } from '@angular/core';

@Component({
  selector: 'app-game-info',
  templateUrl: './game-info.component.html',
  styleUrls: ['./game-info.component.scss']
})
export class GameInfoComponent implements OnInit, OnChanges {
  cardAction = [
    { title: 'Waterfall', description: 'Everyone has to start drinking at the same time. As soon as player 1 stops drinking, player...' },
    { title: 'You', description: 'You decide who drinks 🍻' },
    { title: 'Me', description: 'Congrats! Drink a shot!' },
    { title: 'Category', description: 'Come up with a category (e.g. Colors). Each player must enumerate one item from the category.' },
    { title: 'Bust a jive', description: 'Player 1 makes a dance move. Player 2 repeats the dance move and adds a second one. 🎵' },
    { title: 'Chicks', description: 'All girls drink.' },
    { title: 'Heaven', description: 'Put your hands up! The last player drinks!' },
    { title: 'Mate', description: 'Pick a mate. Your mate must always drink when you drink and the other way around.' },
    { title: 'Thumbmaster', description: '' },
    { title: 'Men', description: 'All men drink.' },
    { title: 'Quizmaster', description: '' },
    { title: 'Never have I ever...', description: 'Say something you never did. Everyone who did it has to drink.' },
    { title: 'Rule', description: 'Make a rule. Everyone needs to drink when he breaks the rule.' },
  ];
  constructor() {}

  title : string = '';
  description = '';
  @Input() card: string;

  ngOnInit(): void {
  }

  ngOnChanges(): void {
    if (this.card) {
      const match = this.card.match(/_(\d+)/); // findet alles nach dem Unterstrich
      if (match && match[1]) {
        const cardNumber = +match[1]; // sicherer cast
        const cardData = this.cardAction[cardNumber - 1];

        if (cardData) {
          this.title = cardData.title;
          this.description = cardData.description;
        }
      }
    }
  }
}
