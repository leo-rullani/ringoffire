from django.urls import path
from .views import markets_view, market_single_view, sellers_view, sellers_single_view

urlpatterns = [
    # List- und Create-Endpunkt für Markets
    path('market/', markets_view, name='market_list'),

    # Detail-Endpunkt für einen einzelnen Market (mit Slash und Name)
    path('market/<int:pk>/', market_single_view, name='market_single'),

    # List- und Create-Endpunkt für Sellers
    path('seller/', sellers_view, name='seller_list'),

    # Detail-Endpunkt für einen einzelnen Seller (mit Slash und Name)
    path('seller/<int:pk>/', sellers_single_view, name='seller_single'),
]