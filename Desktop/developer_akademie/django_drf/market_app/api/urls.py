# market_app/api/urls.py

from django.urls import path, include
from .views import ProductViewSet, MarketsView, MarketSingleView, SellerOfMarketList, sellers_view, sellers_single_view
from rest_framework import routers

# Wenn kein ProductViewSet vorhanden ist, die Router-Registrierung entfernen:
router = routers.SimpleRouter()
router.register(r'products', ProductViewSet)

urlpatterns = [
    path('', include(router.urls)),
    # List- und Create-Endpunkt für Markets
    path('market/', MarketsView.as_view(), name='market_list'),

    # Detail-View für einen einzelnen Market
    path('market/<int:pk>/', MarketSingleView.as_view(), name='market-detail'),
    path('market/<int:pk>/sellers/', SellerOfMarketList.as_view()),

    # List- und Create-Endpunkt für Sellers
    path('seller/', sellers_view, name='seller_list'),

    # Detail-Endpunkt für einen einzelnen Seller
    path('seller/<int:pk>/', sellers_single_view, name='seller-detail'),
]