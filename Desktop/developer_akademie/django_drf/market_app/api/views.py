# market_app/api/views.py

from rest_framework.decorators import api_view
from rest_framework.response import Response
from rest_framework import status
from django.shortcuts import get_object_or_404

from .serializers import ProductSerializer, MarketSerializer, SellerSerializer, MarketHyperlinkedSerializer, SellerListSerializer
from market_app.models import Market, Seller, Product
from rest_framework import mixins, generics, viewsets

class ListRetrieveViewSet(mixins.ListModelMixin, mixins.RetrieveModelMixin, viewsets.GenericViewSet):
    pass

class ProductViewSet(ListRetrieveViewSet):
    queryset = Product.objects.all()
    serializer_class = ProductSerializer

class MarketsView(generics.ListCreateAPIView):
    queryset = Market.objects.all()
    serializer_class = MarketSerializer
    
class MarketSingleView(generics.RetrieveUpdateDestroyAPIView):
    queryset = Market.objects.all()
    serializer_class = MarketSerializer

class SellerOfMarketList(generics.ListCreateAPIView):
    serializer_class = SellerListSerializer
    
    def get_queryset(self):
        pk = self.kwargs.get('pk')
        market = get_object_or_404(Market, pk=pk)
        return market.sellers.all()
    
    def perform_create(self, serializer):
        pk = self.kwargs.get('pk')
        market = Market.objects.get(pk=pk)
        serializer.save(market=market)    
    
    
class MarketDetailView(mixins.RetrieveModelMixin,
                       mixins.UpdateModelMixin,
                       mixins.DestroyModelMixin,
                       generics.GenericAPIView):
    """
    Detail-View für ein einzelnes Market-Objekt:
    - GET    -> RetrieveModelMixin
    - PUT    -> UpdateModelMixin
    - DELETE -> DestroyModelMixin
    """
    queryset = Market.objects.all()
    serializer_class = MarketSerializer

    def get(self, request, *args, **kwargs):
        return self.retrieve(request, *args, **kwargs)

    def put(self, request, *args, **kwargs):
        return self.update(request, *args, **kwargs)

    def delete(self, request, *args, **kwargs):
        return self.destroy(request, *args, **kwargs)


@api_view(['GET', 'POST'])
def markets_view(request):

    if request.method == 'GET':
        markets = Market.objects.all()
        serializer = MarketHyperlinkedSerializer(
            markets,
            many=True,
            context={'request': request},
            fields=('id', 'name', 'net_worth')
        )
        return Response(serializer.data)

    if request.method == 'POST':
        serializer = MarketSerializer(data=request.data, context={'request': request})
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        else:
            return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
    

@api_view(['GET', 'DELETE', 'PUT'])
def market_single_view(request, pk):

    if request.method == 'GET':
        market = get_object_or_404(Market, pk=pk)
        serializer = MarketSerializer(market, context={'request': request})
        return Response(serializer.data)
    
    if request.method == 'PUT':
        market = get_object_or_404(Market, pk=pk)
        serializer = MarketSerializer(market, data=request.data, partial=True, context={'request': request})
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data)
        else:
            return Response(serializer.errors)
        
    
    if request.method == 'DELETE':
        market = get_object_or_404(Market, pk=pk)
        serializer = MarketSerializer(market, context={'request': request})
        market.delete()
        return Response(serializer.data)


@api_view()
def sellers_single_view(request, pk):
    if request.method == 'GET':
        seller = get_object_or_404(Seller, pk=pk)
        serializer = SellerSerializer(seller, context={'request': request})
        return Response(serializer.data)
    

@api_view(['GET', 'POST'])
def sellers_view(request):

    if request.method == 'GET':
        sellers = Seller.objects.all()
        serializer = SellerSerializer(sellers, many=True, context={'request': request})
        return Response(serializer.data)
    
    if request.method == 'POST':
        serializer = SellerSerializer(data=request.data, context={'request': request})
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data)
        else:
            return Response(serializer.errors)