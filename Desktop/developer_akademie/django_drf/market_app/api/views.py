# market_app/api/views.py

from rest_framework.decorators import api_view
from rest_framework.response import Response
from rest_framework import status
from .serializers import MarketSerializer, SellerSerializer, MarketHyperlinkedSerializer
from market_app.models import Market, Seller
from rest_framework.views import APIView
from rest_framework import mixins
from rest_framework import generics


class MarketsView(generics.ListCreateAPIView):
    
    queryset = Market.objects.all()
    serializer_class = MarketSerializer

    # def get(self, request, *args, **kwargs):
    #   return self.list(request, *args, **kwargs)
    
    # def post(self, request, *args, **kwargs):
    #     return self.create(request, *args, **kwargs)


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
        market = Market.objects.get(pk=pk)
        serializer = MarketSerializer(market, context={'request': request})
        return Response(serializer.data)
    
    if request.method == 'PUT':
        market = Market.objects.get(pk=pk)
        serializer = MarketSerializer(market, data=request.data, partial=True, context={'request': request})
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data)
        else:
            return Response(serializer.errors)
        
    
    if request.method == 'DELETE':
        market = Market.objects.get(pk=pk)
        serializer = MarketSerializer(market, context={'request': request})
        market.delete()
        return Response(serializer.data)


@api_view()
def sellers_single_view(request, pk):
    if request.method == 'GET':
        seller = Seller.objects.get(pk=pk)
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
