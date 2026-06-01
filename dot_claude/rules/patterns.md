# Python 実装パターン

## API設計の標準パターン

FastAPI + クリーンアーキテクチャ（4層）をすべてのAPI設計の基準とします。

## FastAPI + クリーンアーキテクチャ設計

### 標準構成（4層アーキテクチャ）

```
┌─────────────────────────────────────────┐
│ API層（HTTP）                           │
│ - FastAPI ルータ                        │
│ - リクエスト/レスポンス処理                │
│ - Serializer（API <-> Entity）         │
└────────────────┬────────────────────────┘
                 │ 呼び出し
                 ↓
┌─────────────────────────────────────────┐
│ Usecase層                               │
│ - ビジネスロジック調整                    │
│ - フロー管理                              │
│ - 各ハンドラー（create, update等）       │
└────────────────┬────────────────────────┘
                 │ 依存
                 ↓
┌─────────────────────────────────────────┐
│ Domain層                                │
│ - ビジネスロジック                        │
│ - Entity（値オブジェクト）                │
│ - Serializer（変換処理）                │
│ - Service（業務ロジック）                │
│ - Interface（契約定義）                 │
└────────────────┬────────────────────────┘
                 ↑ 実装
                 │
┌─────────────────────────────────────────┐
│ Technology層                            │
│ - 技術実装                               │
│ - Provider（外部API連携）               │
│ - Repository（DB操作）                  │
│ - Models（スキーマ）                     │
└────────────────┬────────────────────────┘
                 │ 呼び出し
                 ↓
         ┌───────────────────┐
         │ 外部システム        │
         │ - REST API        │
         │ - データベース      │
         │ - キューサービス等  │
         └───────────────────┘
```

### ディレクトリ構造

```
src/
├── __init__.py
├── main.py                          # FastAPI アプリケーション定義
├── app/
│   ├── __init__.py
│   ├── api/                         # API層
│   │   ├── __init__.py
│   │   ├── {resource}_router.py    # ルータ（エンドポイント定義）
│   │   └── serializer/             # リクエスト/レスポンス変換
│   │       ├── __init__.py
│   │       └── {resource}_serializer.py
│   ├── usecase/                    # Usecase層
│   │   ├── __init__.py
│   │   ├── {resource}_use_case.py  # ユースケース実装
│   │   ├── injector/               # 依存注入
│   │   │   ├── __init__.py
│   │   │   └── {service}_injector.py
│   │   └── error.py                # Usecase層エラー
│   ├── domain/                     # Domain層
│   │   ├── __init__.py
│   │   ├── entity/                 # エンティティ定義
│   │   │   ├── __init__.py
│   │   │   ├── db/                 # DB用エンティティ
│   │   │   └── {external_service}/ # 外部システム用エンティティ
│   │   ├── interface/              # インターフェース定義
│   │   │   ├── __init__.py
│   │   │   ├── providers/
│   │   │   ├── repositories/
│   │   │   └── services/
│   │   ├── serializer/             # エンティティ変換
│   │   │   ├── __init__.py
│   │   │   └── {resource}_serializer.py
│   │   ├── services/               # ビジネスサービス
│   │   │   ├── __init__.py
│   │   │   └── {service}_service.py
│   │   └── value_objects.py        # 値オブジェクト
│   └── technology/                 # Technology層
│       ├── __init__.py
│       ├── models/                 # スキーマ・モデル
│       │   ├── __init__.py
│       │   └── {external_service}/
│       ├── providers/              # 外部API連携
│       │   ├── __init__.py
│       │   └── {service}_provider.py
│       ├── repositories/           # DB操作
│       │   ├── __init__.py
│       │   └── {resource}_repository.py
│       └── error.py                # Technology層エラー
└── tests/
    ├── __init__.py
    ├── api/
    ├── domain/
    └── integration/
```

### 処理フロー例

```
HTTP Request
    ↓
API Router (transaction_mail_router.py)
    - @router.post("/")
    - リクエスト検証
    ↓
API Serializer
    - CreateTransactionMailRequest → TransactionMailEntityForCreate
    ↓
Usecase (transaction_mail_use_case.py)
    - create_handler()
    ├─ Domain Serializer
    │  (API Entity → Domain Entity)
    ├─ MarketingAutomationService
    │  (Domain Service)
    │  ├─ Domain Interface → Technology Provider
    │  │  (EngagePlusProvider)
    │  └─ Domain Interface → Technology Repository
    │     (TransactionMailRepository)
    ├─ DeliveryJobService
    │  (Domain Service)
    │  └─ Technology Provider
    │     (PrefectProvider)
    └─ ChangeHistoryRepository
       (Technology Repository)
    ↓
Domain Serializer
    - Domain Entity → Technology Entity
    ↓
Technology Implementation
    - Provider: 外部API呼び出し
    - Repository: DB操作
    ↓
API Serializer
    - Domain Entity → Response Model
    ↓
HTTP Response
```

### 各層の詳細

#### API層（ルータ + Serializer）

**責務:**

- HTTPエンドポイント定義
- リクエスト/レスポンスの検証と変換
- ステータスコード管理
- エラーハンドリング

**実装例:**

```python
# app/api/product_router.py
from fastapi import APIRouter, Depends, status
from sqlalchemy.ext.asyncio import AsyncSession
from common.app.technology.repositories.database.session import get_session
from product.app.api.serializer import ProductRequestSerializer
from product.app.usecase.product_use_case import ProductUseCase
from shared.schema.request.product import CreateProductRequest
from shared.schema.response.product import GetProductResponse

router = APIRouter(prefix="/products")

@router.get("/{product_id}", response_model=GetProductResponse, status_code=status.HTTP_200_OK)
async def get(product_id: int, session: AsyncSession = Depends(get_session)):
    """製品情報を取得する"""
    use_case = ProductUseCase(session)
    result = await use_case.get_handler(product_id)
    return result

@router.post("/", response_model=dict, status_code=status.HTTP_201_CREATED)
async def create(
    request: CreateProductRequest,
    session: AsyncSession = Depends(get_session)
):
    """製品を登録する"""
    use_case = ProductUseCase(session)
    serializer = ProductRequestSerializer()
    entity = serializer.from_request(request)
    result = await use_case.create_handler(entity)
    return result
```

**特徴:**

- Pydantic schema で リクエスト/レスポンス検証
- `Depends()` で 依存注入
- 最小限のロジック（Usecase へ委譲）
- ステータスコード明示的指定

#### Usecase層

**責務:**

- ビジネスロジック調整
- 複数のサービス/リポジトリの連携
- トランザクション管理
- エラーハンドリング

**実装例:**

```python
# app/usecase/product_use_case.py
class ProductUseCase:
    def __init__(self, session: AsyncSession | None) -> None:
        # 依存注入
        self.product_repo = product_repository_injector(session)
        self.inventory_service = inventory_service_injector()
        self.audit_repo = audit_repository_injector(session)

    async def create_handler(self, request: ProductEntityForCreate) -> dict[str, str]:
        """製品を登録する"""
        # 既存チェック
        existing = await self.product_repo.get_by_sku(request.sku)
        if existing:
            raise ApplicationError(
                kind=ResourceKind.PRODUCT,
                message=f"Product with SKU {request.sku} already exists."
            )

        # Domain Service 呼び出し
        inventory_service = inventory_service_injector()
        inventory_data = await inventory_service.initialize_inventory(request)

        # Repository 呼び出し
        product = await self.product_repo.create(request)
        await self.audit_repo.record(
            resource_type=ResourceKind.PRODUCT,
            resource_id=product.id,
            operation=OperationType.CREATE
        )

        return {"product_id": product.id}
```

**特徴:**

- injector で 依存注入
- 複数層の連携を調整
- ハンドラーメソッド（create_handler, update_handler等）
- ApplicationError, DomainError を適切に使い分け

#### Domain層

**責務:**

- ビジネスロジック実装
- エンティティ（値オブジェクト）定義
- Service（複雑な業務ロジック）
- Interface（Domain ↔ Technology の契約）
- Serializer（エンティティ間の変換）

**Entity例:**

```python
# app/domain/entity/product.py
from dataclasses import dataclass
from datetime import datetime

@dataclass
class ProductEntityForCreate:
    """製品作成用エンティティ"""
    sku: str
    name: str
    description: str
    price: float
    category_id: int
    created_at: datetime
    updated_at: datetime

@dataclass
class ProductEntity:
    """製品エンティティ"""
    id: int
    sku: str
    name: str
    description: str
    price: float
    category_id: int
    is_active: bool
    created_at: datetime
    updated_at: datetime

    def is_available(self) -> bool:
        """製品が利用可能か判定"""
        return self.is_active and self.price > 0
```

**Service例:**

```python
# app/domain/services/inventory_service.py
from abc import ABC, abstractmethod

class InventoryService(ABC):
    @abstractmethod
    async def initialize_inventory(
        self, product: ProductEntityForCreate
    ) -> dict:
        """在庫を初期化"""
        pass

    @abstractmethod
    async def reserve_stock(self, product_id: int, quantity: int) -> bool:
        """在庫を予約"""
        pass
```

**Serializer例:**

```python
# app/domain/serializer/product_serializer.py
class ProductSerializer:
    @staticmethod
    def from_request(request: CreateProductRequest) -> ProductEntityForCreate:
        """API Request → Domain Entity"""
        return ProductEntityForCreate(
            sku=request.sku,
            name=request.name,
            description=request.description,
            price=request.price,
            category_id=request.category_id,
            created_at=datetime.now(),
            updated_at=datetime.now()
        )

    @staticmethod
    def to_response(entity: ProductEntity) -> GetProductResponse:
        """Domain Entity → API Response"""
        return GetProductResponse(
            id=entity.id,
            sku=entity.sku,
            name=entity.name,
            description=entity.description,
            price=entity.price,
            is_available=entity.is_available()
        )
```

#### Technology層

**責務:**

- 技術実装（外部API、DB）
- Domain Interface の実装
- 外部システムとの通信

**Provider例（外部API）:**

```python
# app/technology/providers/payment_provider.py
from abc import ABC, abstractmethod

class PaymentProviderInterface(ABC):
    @abstractmethod
    async def validate_payment(self, amount: float, payment_token: str) -> bool:
        """支払いを検証"""
        pass

    @abstractmethod
    async def process_payment(self, order_id: int, amount: float) -> dict:
        """支払いを処理"""
        pass

class PaymentProvider(PaymentProviderInterface):
    async def validate_payment(self, amount: float, payment_token: str) -> bool:
        """支払いを検証"""
        # 実装: 外部 API 呼び出し（Stripe等）
        pass

    async def process_payment(self, order_id: int, amount: float) -> dict:
        """支払いを処理"""
        # 実装: 外部 API 呼び出し
        pass
```

**Repository例（DB）:**

```python
# app/technology/repositories/product_repository.py
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession
from product.app.domain.entity.product import ProductEntity, ProductEntityForCreate
from product.app.technology.models.product import ProductModel

class ProductRepositoryImpl:
    def __init__(self, session: AsyncSession):
        self.session = session

    async def find_by_id(self, product_id: int) -> ProductEntity | None:
        """ID で製品を取得"""
        stmt = select(ProductModel).where(ProductModel.id == product_id)
        result = await self.session.execute(stmt)
        row = result.scalars().first()
        return self._to_entity(row) if row else None

    async def get_by_sku(self, sku: str) -> ProductEntity | None:
        """SKU で製品を取得"""
        stmt = select(ProductModel).where(ProductModel.sku == sku)
        result = await self.session.execute(stmt)
        row = result.scalars().first()
        return self._to_entity(row) if row else None

    async def create(self, entity: ProductEntityForCreate) -> ProductEntity:
        """製品を作成"""
        model = ProductModel(
            sku=entity.sku,
            name=entity.name,
            description=entity.description,
            price=entity.price,
            category_id=entity.category_id
        )
        self.session.add(model)
        await self.session.flush()
        return self._to_entity(model)

    async def update(self, product_id: int, entity: ProductEntityForCreate) -> ProductEntity:
        """製品を更新"""
        stmt = select(ProductModel).where(ProductModel.id == product_id)
        result = await self.session.execute(stmt)
        model = result.scalars().first()
        if not model:
            raise ValueError(f"Product {product_id} not found")

        model.name = entity.name
        model.description = entity.description
        model.price = entity.price
        await self.session.flush()
        return self._to_entity(model)

    def _to_entity(self, model: ProductModel) -> ProductEntity:
        """ORM モデル → エンティティ変換"""
        return ProductEntity(
            id=model.id,
            sku=model.sku,
            name=model.name,
            description=model.description,
            price=model.price,
            category_id=model.category_id,
            is_active=model.is_active,
            created_at=model.created_at,
            updated_at=model.updated_at
        )
```

### 依存関係の原則

```
✅ 許可される依存方向:
- API層 → Usecase層
- Usecase層 → Domain層 + Technology層
- Technology層 → Domain Interface（実装）
- Technology層 → 外部システム

❌ 禁止される依存方向:
- Domain層 → API層
- Domain層 → Technology層（直接依存）
- Technology層 → Usecase層
```

### 実装ガイドライン

**新機能実装時:**

1. **Domain層から開始**
   - Entity（値オブジェクト）定義
   - Interface（Service、Provider、Repository）定義
   - Business Logic 実装

2. **Usecase層を実装**
   - 各ハンドラー（create_handler, update_handler等）
   - Domain Service の連携
   - Repository の操作

3. **Technology層を実装**
   - Interface の実装
   - Provider（外部API）
   - Repository（DB操作）

4. **API層を実装**
   - Router（エンドポイント）
   - Serializer（リクエスト/レスポンス変換）

**テスト戦略:**

```
Domain層: ビジネスロジックのユニットテスト
         モック Repository/Provider を使用

Usecase層: 統合テスト
          モック Repository/Provider を使用

Technology層: 統合テスト
             実 DB/API との連携テスト

API層: E2E テスト
      Playwright、pytest 使用
```

**エラーハンドリング:**

```python
# Domain層: DomainError
raise DomainError(code="INVALID_STATE", message="...")

# Usecase層: ApplicationError
raise ApplicationError(kind=ResourceKind.TRANSACTION_MAIL, message="...")

# API層: HTTPException
raise HTTPException(status_code=400, detail="...")
```

## API レスポンス構造

```python
def get_response(success: bool, data=None, error=None, meta=None):
    return {
        "success": success,
        "data": data,
        "error": error,
        "meta": meta or {}
    }

# 使用例
response = get_response(
    success=True,
    data={"id": 1, "name": "user"},
    meta={"total": 100, "page": 1, "limit": 20}
)
```

## リポジトリパターン

```python
from abc import ABC, abstractmethod

class Repository(ABC):
    @abstractmethod
    def find_all(self, filters=None):
        pass

    @abstractmethod
    def find_by_id(self, id):
        pass

    @abstractmethod
    def create(self, data):
        pass

    @abstractmethod
    def update(self, id, data):
        pass

    @abstractmethod
    def delete(self, id):
        pass
```

## FastAPI + クリーンアーキテクチャ

### ディレクトリ構造

```
src/
├── api/                    # ルータ層（HTTP）
│   ├── __init__.py
│   ├── depen/Users/user/Documents/work/src/transaction_maildencies.py     # 依存注入
│   └── v1/
│       ├── markets.py      # マーケットエンドポイント
│       ├── users.py        # ユーザーエンドポイント
│       └── routes.py       # ルート集約
├── application/            # ユースケース層
│   ├── __init__.py
│   ├── dtos.py            # リクエスト/レスポンスモデル
│   └── use_cases/
│       ├── create_market.py
│       ├── search_markets.py
│       └── get_market_detail.py
├── domain/                 # エンティティ層
│   ├── __init__.py
│   └── models/
│       ├── market.py       # Market エンティティ
│       ├── user.py         # User エンティティ
│       └── value_objects.py
├── infrastructure/         # データアクセス層
│   ├── __init__.py
│   ├── persistence/
│   │   ├── repositories/
│   │   │   ├── market_repository.py
│   │   │   └── user_repository.py
│   │   └── database.py
│   └── external/
│       ├── search_service.py
│       └── blockchain.py
└── main.py                # FastAPI アプリケーション
```

### エンティティ（Domain層）

```python
# src/domain/models/market.py
from dataclasses import dataclass
from datetime import datetime

@dataclass
class Market:
    """市場ドメインモデル"""
    id: str
    name: str
    description: str
    creator_id: str
    created_at: datetime
    ends_at: datetime

    def is_active(self) -> bool:
        """市場がアクティブか判定"""
        return datetime.now() < self.ends_at

    def is_expired(self) -> bool:
        """市場が期限切れか判定"""
        return datetime.now() >= self.ends_at
```

### リポジトリ（Infrastructure層）

```python
# src/infrastructure/persistence/repositories/market_repository.py
from abc import ABC, abstractmethod
from typing import list, Optional
from domain.models.market import Market

class MarketRepository(ABC):
    @abstractmethod
    async def find_by_id(self, market_id: str) -> Optional[Market]:
        pass

    @abstractmethod
    async def find_all(self, skip: int = 0, limit: int = 10) -> list[Market]:
        pass

    @abstractmethod
    async def create(self, market: Market) -> Market:
        pass

    @abstractmethod
    async def update(self, market_id: str, market: Market) -> Market:
        pass

    @abstractmethod
    async def delete(self, market_id: str) -> None:
        pass
```

### ユースケース（Application層）

```python
# src/application/use_cases/get_market_detail.py
from typing import Optional
from domain.models.market import Market
from infrastructure.persistence.repositories.market_repository import MarketRepository

class GetMarketDetailUseCase:
    def __init__(self, market_repo: MarketRepository):
        self.market_repo = market_repo

    async def execute(self, market_id: str) -> Optional[Market]:
        """市場詳細を取得"""
        market = await self.market_repo.find_by_id(market_id)
        if not market:
            raise ValueError(f'Market {market_id} not found')
        return market
```

### DTO（Application層）

```python
# src/application/dtos.py
from pydantic import BaseModel, Field
from datetime import datetime
from typing import Optional

class MarketCreateRequest(BaseModel):
    """市場作成リクエスト"""
    name: str = Field(..., min_length=1, max_length=200)
    description: str = Field(..., min_length=1, max_length=5000)
    ends_at: datetime

class MarketResponse(BaseModel):
    """市場レスポンス"""
    id: str
    name: str
    description: str
    creator_id: str
    is_active: bool
    created_at: datetime
    ends_at: datetime

    class Config:
        from_attributes = True
```

### エンドポイント（API層）

```python
# src/api/v1/markets.py
from fastapi import APIRouter, Depends, HTTPException
from typing import list
from application.dtos import MarketCreateRequest, MarketResponse
from application.use_cases.get_market_detail import GetMarketDetailUseCase
from api.dependencies import get_market_repository

router = APIRouter(prefix='/markets', tags=['markets'])

@router.get('/{market_id}', response_model=MarketResponse)
async def get_market(
    market_id: str,
    repo=Depends(get_market_repository)
):
    """市場詳細取得"""
    use_case = GetMarketDetailUseCase(repo)
    try:
        market = await use_case.execute(market_id)
        return market
    except ValueError as e:
        raise HTTPException(status_code=404, detail=str(e))

@router.post('', response_model=MarketResponse, status_code=201)
async def create_market(
    request: MarketCreateRequest,
    repo=Depends(get_market_repository)
):
    """市場作成"""
    # ユースケース実行
    market = await create_market_use_case.execute(request)
    return market
```

### 依存注入（API層）

```python
# src/api/dependencies.py
from fastapi import Depends
from infrastructure.persistence.repositories.market_repository import MarketRepository
from infrastructure.persistence.database import get_db

async def get_market_repository(
    db=Depends(get_db)
) -> MarketRepository:
    """MarketRepository を注入"""
    return MarketRepository(db)
```

### メインアプリケーション

```python
# src/main.py
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from api.v1.routes import router as v1_router

app = FastAPI(
    title='API',
    version='1.0.0',
    description='クリーンアーキテクチャベースのAPI'
)

# CORS設定
app.add_middleware(
    CORSMiddleware,
    allow_origins=['http://localhost:3000'],
    allow_credentials=True,
    allow_methods=['*'],
    allow_headers=['*']
)

# ルータ登録
app.include_router(v1_router, prefix='/api/v1')

@app.get('/health')
async def health():
    return {'status': 'ok'}
```

## 新機能実装の進め方

1. 既存コードパターンを確認
2. 同じパターンで実装
3. 複数の実装方法がある場合:
   - セキュリティ評価
   - 拡張性チェック
   - 既存プロジェクトとの整合性
4. 実証済みの構造を選択
