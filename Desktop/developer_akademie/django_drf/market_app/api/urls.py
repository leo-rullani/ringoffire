# market_app/api/urls.py

from django.urls import path
from .views import MarketsView, MarketDetailView, sellers_view, sellers_single_view

urlpatterns = [
    # List- und Create-Endpunkt für Markets
    path('market/', MarketsView.as_view(), name='market_list'),

    # Mixin-basierte Detail-View für einen einzelnen Market
    path('market/<int:pk>/', MarketDetailView.as_view(), name='market-detail'),

    # List- und Create-Endpunkt für Sellers
    path('seller/', sellers_view, name='seller_list'),

    # Detail-Endpunkt für einen einzelnen Seller
    path('seller/<int:pk>/', sellers_single_view, name='seller_single'),
]