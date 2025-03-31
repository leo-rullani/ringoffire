import { ComponentFixture, TestBed } from '@angular/core/testing';

import { EnvironmentsComponent } from './environments.component';

describe('EnvironmentsComponent', () => {
  let component: EnvironmentsComponent;
  let fixture: ComponentFixture<EnvironmentsComponent>;

  beforeEach(() => {
    TestBed.configureTestingModule({
      declarations: [EnvironmentsComponent]
    });
    fixture = TestBed.createComponent(EnvironmentsComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
